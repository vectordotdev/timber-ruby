require "base64"
require "net/https"

module Timber
  module LogDevices
    # A highly efficient log device that buffers and delivers log messages over HTTPS to
    # the Timber API. It uses batches, keep-alive connections, and msgpack to deliver logs with
    # high-throughput and little overhead. All log preparation and delivery is done asynchronously
    # in a thread as not to block application execution.
    #
    # See {#initialize} for options and more details.
    class HTTP
      # @private
      class LogMsgQueue
        def initialize(max_size)
          @lock = Mutex.new
          @max_size = max_size
          @array = []
        end

        def enqueue(msg)
          @lock.synchronize do
            @array << msg
          end
        end

        def flush
          @lock.synchronize do
            old = @array
            @array = []
            return old
          end
        end

        def full?
          size >= @max_size
        end

        def size
          @array.size
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
      CONTENT_TYPE = "application/msgpack".freeze
      USER_AGENT = "Timber Ruby/#{Timber::VERSION} (HTTP)".freeze


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
      # @option attributes [Symbol] :batch_size (1000) Determines the maximum of log lines in
      #   each HTTP payload. If the queue exceeds this limit an HTTP request will be issued. Bigger
      #   payloads mean higher throughput, but also use more memory. Timber will not accept
      #   payloads larger than 1mb.
      # @option attributes [Symbol] :flush_continuously (true) This should only be disabled under
      #   special circumstsances (like test suites). Setting this to `false` disables the
      #   continuous flushing of log message. As a result, flushing must be handled externally
      #   via the #flush method.
      # @option attributes [Symbol] :flush_interval (1) How often the client should
      #   attempt to deliver logs to the Timber API in fractional seconds. The HTTP client buffers
      #   logs and this options represents how often that will happen, assuming `:batch_byte_size`
      #   is not met.
      # @option attributes [Symbol] :requests_per_conn (2500) The number of requests to send over a
      #   single persistent connection. After this number is met, the connection will be closed
      #   and a new one will be opened.
      # @option attributes [Symbol] :request_queue (SizedQueue.new(3)) The request queue object that queues Net::HTTP
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
        @api_key = api_key || raise(ArgumentError.new("The api_key parameter cannot be blank"))
        @timber_url = URI.parse(options[:timber_url] || ENV['TIMBER_URL'] || TIMBER_URL)
        @batch_size = options[:batch_size] || 1_000
        @flush_continuously = options[:flush_continuously] != false
        @flush_interval = options[:flush_interval] || 1 # 1 second
        @requests_per_conn = options[:requests_per_conn] || 2_500
        @msg_queue = LogMsgQueue.new(@batch_size)
        @request_queue = options[:request_queue] || SizedQueue.new(3)
        @successive_error_count = 0
        @requests_in_flight = 0
      end

      # Write a new log line message to the buffer, and deliver if the msg exceeds the
      # payload limit.
      def write(msg)
        @msg_queue.enqueue(msg)

        # Lazily start flush threads to ensure threads are alive after forking processes.
        # If the threads are started during instantiation they will not be copied when
        # the current process is forked. This is the case with various web servers,
        # such as phusion passenger.
        ensure_flush_threads_are_started

        if @msg_queue.full?
          debug_logger.debug("Flushing HTTP buffer via write") if debug_logger
          flush
        end
        true
      end

      def flush
        @last_flush = Time.now
        msgs = @msg_queue.flush
        return if msgs.empty?

        req = Net::HTTP::Post.new(@timber_url.path)
        req['Authorization'] = authorization_payload
        req['Content-Type'] = CONTENT_TYPE
        req['User-Agent'] = USER_AGENT
        req.body = msgs.to_msgpack
        @request_queue.enq(req)
      end

      # Closes the log device, cleans up, and attempts one last delivery.
      def close
        # Kill the flush thread immediately since we are about to flush again.
        @flush_thread.kill if @flush_thread

        # Flush all remaining messages
        flush

        # Kill the request_outlet thread gracefully. We do not want to kill it while a
        # request is inflight. Ideally we'd let it finish before we die.
        if @request_outlet_thread
          4.times do
            if @requests_in_flight == 0 && @request_queue.size == 0
              @request_outlet_thread.kill
              break
            else
              debug_logger.error("Busy delivering the final log messages, " +
                "connection will close when complete.")
              sleep 1
            end
          end
        end
      end

      private
        def debug_logger
          Timber::Config.instance.debug_logger
        end

        # This is a convenience method to ensure the flush thread are
        # started. This is called lazily from #write so that we
        # only start the threads as needed, but it also ensures
        # threads are started after process forking.
        def ensure_flush_threads_are_started
          if @flush_continuously
            if @request_outlet_thread.nil? || !@request_outlet_thread.alive?
              @request_outlet_thread = Thread.new { request_outlet }
            end

            if @flush_thread.nil? || !@flush_thread.alive?
              @flush_thread = Thread.new { intervaled_flush }
            end
          end
        end

        def intervaled_flush
          # Wait specified time period before starting
          sleep @flush_interval

          loop do
            begin
              if intervaled_flush_ready?
                debug_logger.debug("Flushing HTTP buffer via the interval") if debug_logger
                flush
              end

              sleep(0.5)
            rescue Exception => e
              logger.error("Intervaled HTTP flush failed: #{e.inspect}\n\n#{e.backtrace}")
            end
          end
        end

        def intervaled_flush_ready?
          @last_flush.nil? || (Time.now.to_f - @last_flush.to_f).abs >= @flush_interval
        end

        def build_http
          http = Net::HTTP.new(@timber_url.host, @timber_url.port)
          http.set_debug_output(debug_logger) if debug_logger
          http.use_ssl = true if @timber_url.scheme == 'https'
          http.read_timeout = 30
          http.ssl_timeout = 10
          http.open_timeout = 10
          http
        end

        def request_outlet
          loop do
            http = build_http

            begin
              debug_logger.info("Starting HTTP connection") if debug_logger

              http.start do |conn|
                deliver_requests(conn)
              end
            rescue => e
              debug_logger.error("#request_outlet error: #{e.message}") if debug_logger
            ensure
              debug_logger.info("Finishing HTTP connection") if debug_logger
              http.finish if http.started?
            end
          end
        end

        def deliver_requests(conn)
          num_reqs = 0

          while num_reqs < @requests_per_conn
            debug_logger.info("Waiting on next request, threads waiting: #{@request_queue.num_waiting}") if debug_logger

            # Blocks waiting for a request.
            req = @request_queue.deq
            @requests_in_flight += 1

            begin
              resp = conn.request(req)
            rescue => e
              debug_logger.error("#deliver_request error: #{e.message}") if debug_logger

              @successive_error_count += 1

              # Back off so that we don't hammer the Timber API.
              calculated_backoff = @successive_error_count * 2
              backoff = calculated_backoff > 30 ? 30 : calculated_backoff

              debug_logger.error("Backing off #{backoff} seconds, error ##{@successive_error_count}") if debug_logger

              sleep backoff

              # Throw the request back on the queue for a retry
              @request_queue.enq(req)
              return false
            ensure
              @requests_in_flight -= 1
            end

            @successive_error_count = 0
            num_reqs += 1
            debug_logger.info("Request successful: #{resp.code}") if debug_logger
          end
        end

        def authorization_payload
          @authorization_payload ||= "Basic #{Base64.urlsafe_encode64(@api_key).chomp}"
        end
    end
  end
end