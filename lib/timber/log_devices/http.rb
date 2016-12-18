module Timber
  module LogDevices
    # A log device that buffers and delivers log messages over HTTPS to the Timber API in batches.
    # The buffer and delivery strategy are very efficient and the log messages will be delivered in
    # msgpack format.
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
            @byteszie += msg.bytesize
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
      # @param api_key [String] The API key provided to you after you add your application to
      #   [Timber](https://timber.io).
      # @param [Hash] options the options to create a HTTP log device with.
      # @option attributes [Symbol] :payload_limit_bytes Determines the maximum size in bytes that
      #   and HTTP payload can be. Please see {TriggereBuffer#initialize} for the default.
      # @option attributes [Symbol] :buffer_limit_bytes Determines the maximum size of the total
      #   buffer. This should be many times larger than the `:payload_limit_bytes`.
      #   Please see {TriggereBuffer#initialize} for the default.
      # @option attributes [Symbol] :buffer_overflow_handler (nil) When a single message exceeds
      #   `:payload_limit_bytes` or the entire buffer exceeds `:buffer_limit_bytes`, the Proc
      #   passed to this option will be called with the msg that would overflow the buffer. See
      #   the examples on how to use this properly.
      # @option attributes [Symbol] :delivery_frequency_seconds (2) How often the client should
      #   attempt to deliver logs to the Timber API. The HTTP client buffers logs between calls.
      #
      # @example Basic usage
      #   Timber::Logger.new(Timber::LogDevices::HTTP.new("my_timber_api_key"))
      #
      # @example Handling buffer overflows
      #   # Persist overflowed lines to a file
      #   # Note: You could write these to any permanent storage.
      #   overflow_log_path = "/path/to/my/overflow_log.log"
      #   overflow_handler = Proc.new { |log_line_msg| File.write(overflow_log_path, log_line_ms) }
      #   http_log_device = Timber::LogDevices::HTTP.new("my_timber_api_key",
      #     buffer_overflow_handler: overflow_handler)
      #   Timber::Logger.new(http_log_device)
      def initialize(api_key, options = {})
        @debug = options[:debug] || ENV['debug']
        @api_key = api_key
        @timber_url = URI.parse(options[:timber_url] || ENV['TIMBER_URL'] || TIMBER_URL)
        @batch_byte_size = opts[:batch_byte_size] || 3_000_000 # 3mb
        @flush_interval = opts[:flush_interval] || 2 # 2 seconds
        @requests_per_conn = opts[:requests_per_conn] || 1_000
        @msg_queue = LogMsgQueue.new(@batch_byte_size)
        @request_queue = opts[:request_queue] || SizedQueue.new(3)

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
        @outlet_thread.kill
        @flush_thread.kill
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

          req = Net::HTTP::Post.new(@logplex_url.path)
          req['Authorization'] = authorization_payload
          req['Content-Type'] = CONTENT_TYPE
          req['User-Agent'] = USER_AGENT
          req.body = body
          @request_queue.enq(req)
          @last_flush = Time.now
        end

        def intervaled_flush
          loop do
            begin
              flush if interval_ready?
              sleep(0.1)
            rescue Exception => e
              logger.error("Timber intervaled flush failed: #{e.inspect}")
            end
          end
        end

        def interval_flush_ready?
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