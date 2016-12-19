module Timber
  module LogDevices
    # A log device that buffers and delivers log messages over HTTPS to the Timber API.
    # It uses batches, keep-alive connections, and messagepack to delivery logs with
    # high-throughput and little overhead.
    #
    # See {#initialize} for options and more details.
    class HTTP
      # @private
      class LogMsgQueue
        MAX_MSG_BYTES = 50_000 # 50kb

        def initialize(max_bytes)
          @lock = Mutex.new
          @max_bytes = max_bytes
          @array = []
          @bytesize = 0
        end

        def enqueue(msg)
          if msg.bytesize > MAX_MSG_BYTES
            raise ArgumentError.new("Log message exceeds the #{MAX_MSG_BYTES} bytes limit")
          end

          @lock.synchronize do
            @array << msg
            @bytesize += msg.bytesize
          end
        end

        def flush
          @lock.synchronize do
            old = @array
            @array = []
            @bytesize = 0
            return old
          end
        end

        def full?
          @lock.synchronize do
            @bytesize >= @max_bytes
          end
        end
      end

      # Works like SizedQueue, but drops message instead of blocking. Pass one of these in
      # to {HTTP#intiialize} via the :request_queue option if you'd prefer to drop messages
      # in the event of a buffer overflow instead of applying back pressure.
      class DroppingSizedQueue < SizedQueue
        # Returns true/false depending on whether the queue is full or not
        def push(obj)
          @mutex.synchronize do
            return false unless @que.length < @max

            @que.push obj
            begin
              t = @waiting.shift
              t.wakeup if t
            rescue ThreadError
              retry
            end
            return true
          end
        end
      end

      TIMBER_URL = "https://logs.timber.io/frames".freeze
      CONTENT_TYPE = "application/x-timber-msgpack-frame-1".freeze
      USER_AGENT = "Timber Ruby Gem/#{Timber::VERSION}".freeze
      DELIVERY_FREQUENCY_SECONDS = 2.freeze
      RETRY_LIMIT = 5.freeze
      BACKOFF_RATE_SECONDS = 3.freeze


      # Instantiates a new HTTP log device that can be passed to {Timber::Logger#initialize}.
      #
      # The class maintains a buffer which is flushed in batches to the Timber API. 2
      # options control when the flush happens, `:batch_byte_size` and `:flush_interval`.
      # If either of these are surpassed, the buffer will be flushed.
      #
      # By default, the buffer will apply back pressure log messages are generated faster than
      # the client can delivery them. But you can drop messages instead by passing a
      # {DroppingSizedQueue} via the `:request_queue` option.
      #
      # @param api_key [String] The API key provided to you after you add your application to
      #   [Timber](https://timber.io).
      # @param [Hash] options the options to create a HTTP log device with.
      # @option attributes [Symbol] :batch_byte_size Determines the maximum size in bytes for
      #   each HTTP payload. If the buffer exceeds this limit a delivery will be attempted.
      # @option attributes [Symbol] :debug Whether to print debug output or not. This is also
      #   inferred from ENV['debug']. Output will be sent to `Timber::Config.logger`.
      # @option attributes [Symbol] :flush_interval (2) How often the client should
      #   attempt to deliver logs to the Timber API. The HTTP client buffers logs and this
      #   options represents how often that will happen, assuming `:batch_byte_size` is not met.
      # @option attributes [Symbol] :requests_per_conn The number of requests to send over a
      #   single persistent connection. After this number is met, the connection will be closed
      #   and a new one will be opened.
      # @option attributes [Symbol] :request_queue The request queue object that queues Net::HTTP
      #   requests for delivery. By deafult this is a `SizedQueue` of size `3`. Meaning once
      #   3 requests are placed on the queue for delivery, back pressure will be applied. IF
      #   you'd prefer to drop messages instead, pass a {DroppingSizedQueue}. See examples for
      #   an example.
      # @option attributes [Symbol] :timber_url The Timber URL to delivery the log lines. The
      #   default is set via {TIMBER_URL}.
      #
      # @example Basic usage
      #   Timber::Logger.new(Timber::LogDevices::HTTP.new("my_timber_api_key"))
      #
      # @example Dropping messages instead of applying back pressure
      #   http_log_device = Timber::LogDevices::HTTP.new("my_timber_api_key",
      #     request_queue: Timber::LogDevices::HTTP::DroppingSizedQueue.new(3))
      #   Timber::Logger.new(http_log_device)
      def initialize(api_key, options = {})
        @api_key = api_key
        @debug = options[:debug] || ENV['debug']
        @timber_url = URI.parse(options[:timber_url] || ENV['TIMBER_URL'] || TIMBER_URL)
        @batch_byte_size = options[:batch_byte_size] || 3_000_000 # 3mb
        @flush_interval = options[:flush_interval] || 2 # 2 seconds
        @requests_per_conn = options[:requests_per_conn] || 1_000
        @msg_queue = LogMsgQueue.new(@batch_byte_size)
        @request_queue = options[:request_queue] || SizedQueue.new(3)

        @outlet_thread = Thread.new { outlet }
        @flush_thread = Thread.new { intervaled_flush }
      end

      # Write a new log line message to the buffer, and deliver if the msg exceeds the
      # payload limit.
      def write(msg)
        @msg_queue.enqueue(msg)
        if @msg_queue.full?
          flush
        end
        true
      end

      # Closes the log device, cleans up, and attempts one last delivery.
      def close
        @flush_thread.kill
        @outlet_thread.kill
        flush
      end

      private
        def debug?
          !@debug.nil?
        end

        def flush
          msgs = @msg_queue.flush
          return if msgs.empty?

          body = ""
          msgs.each do |msg|
            body << msg
          end

          req = Net::HTTP::Post.new(@timber_url.path)
          req['Authorization'] = authorization_payload
          req['Content-Type'] = CONTENT_TYPE
          req['User-Agent'] = USER_AGENT
          req.body = body
          @request_queue.enq(req)
          @last_flush = Time.now
        end

        def intervaled_flush
          # Wait specified time period before starting
          sleep @flush_interval
          loop do
            begin
              if intervaled_flush_ready?
                flush
              end
              sleep(0.1)
            rescue Exception => e
              logger.error("Timber intervaled flush failed: #{e.inspect}")
            end
          end
        end

        def intervaled_flush_ready?
          @last_flush.nil? || (Time.now.to_f - @last_flush.to_f).abs >= @flush_interval
        end

        def outlet
          loop do
            http = Net::HTTP.new(API_URI.host, API_URI.port)
            http.set_debug_output(logger) if debug?
            http.use_ssl = true if @timber_url.scheme == 'https'
            http.read_timeout = 30
            http.ssl_timeout = 10
            http.open_timeout = 10

            begin
              http.start do |conn|
                num_reqs = 0
                while num_reqs < @max_reqs_per_conn
                  #Blocks waiting for a request.
                  req = @request_queue.deq
                  @req_in_flight += 1
                  resp = nil
                  begin
                    resp = conn.request(req)
                  rescue => e
                    logger.error("Timber request error: #{e.message}") if debug?
                    next
                  ensure
                    @req_in_flight -= 1
                  end
                  num_reqs += 1
                  logger.info("Time request successful: #{resp.code}") if debug?
                end
              end
            rescue => e
              logger.error("Timber request error: #{e.message}") if debug?
            ensure
              http.finish if http.started?
            end
          end
        end

        def authorization_payload
          @authorization_payload ||= "Basic #{Base64.strict_encode64(@api_key).chomp}"
        end

        def logger
          Config.instance.logger
        end
    end
  end
end