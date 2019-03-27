require "base64"
require "msgpack"
require "net/https"

require "timber/config"
require "timber/log_devices/http/flushable_dropping_sized_queue"
require "timber/log_devices/http/request_attempt"
require "timber/version"

module Timber
  module LogDevices
    # A highly efficient log device that buffers and delivers log messages over HTTPS to
    # the Timber API. It uses batches, keep-alive connections, and msgpack to deliver logs with
    # high-throughput and little overhead. All log preparation and delivery is done asynchronously
    # in a thread as not to block application execution and efficiently deliver logs for
    # multi-threaded environments.
    #
    # See {#initialize} for options and more details.
    class HTTP
      TIMBER_STAGING_HOST = "logs-staging.timber.io".freeze
      TIMBER_PRODUCTION_HOST = "logs.timber.io".freeze
      TIMBER_HOST = ENV['TIMBER_STAGING'] ? TIMBER_STAGING_HOST : TIMBER_PRODUCTION_HOST
      TIMBER_PORT = 443
      TIMBER_SCHEME = "https".freeze
      CONTENT_TYPE = "application/msgpack".freeze
      USER_AGENT = "Timber Ruby/#{Timber::VERSION} (HTTP)".freeze

      # Instantiates a new HTTP log device that can be passed to {Timber::Logger#initialize}.
      #
      # The class maintains a buffer which is flushed in batches to the Timber API. 2
      # options control when the flush happens, `:batch_byte_size` and `:flush_interval`.
      # If either of these are surpassed, the buffer will be flushed.
      #
      # By default, the buffer will apply back pressure when the rate of log messages exceeds
      # the maximum delivery rate. If you don't want to sacrifice app performance in this case
      # you can drop the log messages instead by passing a {DroppingSizedQueue} via the
      # `:request_queue` option.
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
      # @option attributes [Symbol] :request_queue (FlushableDroppingSizedQueue.new(25)) The request
      #   queue object that queues Net::HTTP requests for delivery. By deafult this is a
      #   `FlushableDroppingSizedQueue` of size `25`. Meaning once the queue fills up to 25
      #   requests new requests will be dropped. If you'd prefer to apply back pressure,
      #   ensuring you do not lose log data, pass a standard {SizedQueue}. See examples for
      #   an example.
      # @option attributes [Symbol] :timber_host The Timber host to delivery the log lines to.
      #   The default is set via {TIMBER_HOST}.
      #
      # @example Basic usage
      #   Timber::Logger.new(Timber::LogDevices::HTTP.new("my_timber_api_key"))
      #
      # @example Apply back pressure instead of dropping messages
      #   http_log_device = Timber::LogDevices::HTTP.new("my_timber_api_key", request_queue: SizedQueue.new(25))
      #   Timber::Logger.new(http_log_device)
      def initialize(api_key, *args)
        options = {}

        # Timber 3.0 introduced a second argument `source_id` which is required for the new
        # Timber API keys. For backwards compability we still support the old source specific
        # API keys that do not require an explicit source ID.
        if args.last.is_a?(Hash)
          options = args.pop
        end

        @api_key = api_key || raise(ArgumentError.new("The api_key parameter cannot be blank"))
        @source_id = args.first
        @timber_host = options[:timber_host] || ENV['TIMBER_HOST'] || TIMBER_HOST
        @timber_port = options[:timber_port] || ENV['TIMBER_PORT'] || TIMBER_PORT
        @timber_scheme = options[:timber_scheme] || ENV['TIMBER_SCHEME'] || TIMBER_SCHEME
        @batch_size = options[:batch_size] || 1_000
        @flush_continuously = options[:flush_continuously] != false
        @flush_interval = options[:flush_interval] || 2 # 2 seconds
        @requests_per_conn = options[:requests_per_conn] || 2_500
        @msg_queue = FlushableDroppingSizedQueue.new(@batch_size)
        @request_queue = options[:request_queue] || FlushableDroppingSizedQueue.new(25)
        @successive_error_count = 0
        @requests_in_flight = 0
      end

      # Write a new log line message to the buffer, and flush asynchronously if the
      # message queue is full. We flush asynchronously because the maximum message batch
      # size is constricted by the Timber API. The actual application limit is a multiple
      # of this. Hence the `@request_queue`.
      def write(msg)
        @msg_queue.enq(msg)

        # Lazily start flush threads to ensure threads are alive after forking processes.
        # If the threads are started during instantiation they will not be copied when
        # the current process is forked. This is the case with various web servers,
        # such as phusion passenger.
        ensure_flush_threads_are_started

        if @msg_queue.full?
          Timber::Config.instance.debug { "Flushing HTTP buffer via write" }
          flush_async
        end
        true
      end

      # Flush all log messages in the buffer synchronously. This method will not return
      # until delivery of the messages has been successful. If you want to flush
      # asynchronously see {#flush_async}.
      def flush
        flush_async
        wait_on_request_queue
        true
      end

      # Closes the log device, cleans up, and attempts one last delivery.
      def close
        # Kill the flush thread immediately since we are about to flush again.
        @flush_thread.kill if @flush_thread

        # Flush all remaining messages
        flush

        # Kill the request queue thread. Flushing ensures that no requests are pending.
        @request_outlet_thread.kill if @request_outlet_thread
      end

      def deliver_one(msg)
        http = build_http

        begin
          resp = http.start do |conn|
            req = build_request([msg])
            @requests_in_flight += 1
            conn.request(req)
          end
          return resp
        rescue => e
          Timber::Config.instance.debug { "error: #{e.message}" }
          return e
        ensure
          http.finish if http.started?
          @requests_in_flight -= 1
        end
      end

      def verify_delivery!
        5.times do |i|
          sleep(2)

          if @last_resp.nil?
            print "."
          elsif @last_resp.code == "202"
            puts "Log delivery successful! View your logs at https://app.timber.io"
          else
            raise <<-MESSAGE

Log delivery failed!

Status: #{@last_resp.code}
Body: #{@last_resp.body}

You can enable internal Timber debug logging with the following:

Timber::Config.instance.debug_logger = ::Logger.new(STDOUT)
MESSAGE
          end
        end

        raise <<-MESSAGE
        
Log delivery failed! No request was made.

You can enable internal debug logging with the following:

Timber::Config.instance.debug_logger = ::Logger.new(STDOUT)
MESSAGE
      end

      private
        # This is a convenience method to ensure the flush thread are
        # started. This is called lazily from {#write} so that we
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

        # Builds an HTTP request based on the current messages queued.
        def build_request(msgs)
          path = @source_id.nil? ? "/frames" : "/sources/#{@source_id}/frames"
          req = Net::HTTP::Post.new(path)
          req['Authorization'] = authorization_payload
          req['Content-Type'] = CONTENT_TYPE
          req['User-Agent'] = USER_AGENT
          req.body = msgs.to_msgpack
          req
        end

        # Flushes the message buffer asynchronously. The reason we provide this
        # method is because the message buffer limit is constricted by the
        # Timber API. The application limit is multiples of the buffer limit,
        # hence the `@request_queue`, allowing us to buffer beyond the Timber API
        # imposed limit.
        def flush_async
          @last_async_flush = Time.now
          msgs = @msg_queue.flush
          return if msgs.empty?

          req = build_request(msgs)
          if !req.nil?
            Timber::Config.instance.debug { "New request placed on queue" }
            request_attempt = RequestAttempt.new(req)
            @request_queue.enq(request_attempt)
          end
        end

        # Waits on the request queue. This is used in {#flush} to ensure
        # the log data has been delivered before returning.
        def wait_on_request_queue
          # Wait 20 seconds
          40.times do |i|
            if @request_queue.size == 0 && @requests_in_flight == 0
              Timber::Config.instance.debug { "Request queue is empty and no requests are in flight, finish waiting" }
              return true
            end
            Timber::Config.instance.debug do
              "Request size #{@request_queue.size}, reqs in-flight #{@requests_in_flight}, " \
                "continue waiting (iteration #{i + 1})"
            end
            sleep 0.5
          end
        end

        # Flushes the message queue on an interval. You will notice that {#write} also
        # flushes the buffer if it is full. This method takes note of this via the
        # `@last_async_flush` variable as to not flush immediately after a write flush.
        def intervaled_flush
          # Wait specified time period before starting
          sleep @flush_interval

          loop do
            begin
              if intervaled_flush_ready?
                Timber::Config.instance.debug { "Flushing HTTP buffer via the interval" }
                flush_async
              end

              sleep(0.5)
            rescue Exception => e
              Timber::Config.instance.debug { "Intervaled HTTP flush failed: #{e.inspect}\n\n#{e.backtrace}" }
            end
          end
        end

        # Determines if the loop in {#intervaled_flush} is ready to be flushed again. It
        # uses the `@last_async_flush` variable to ensure that a flush does not happen
        # too rapidly ({#write} also triggers a flush).
        def intervaled_flush_ready?
          @last_async_flush.nil? || (Time.now.to_f - @last_async_flush.to_f).abs >= @flush_interval
        end

        # Builds an `Net::HTTP` object to deliver requests over.
        def build_http
          http = Net::HTTP.new(@timber_host, @timber_port)
          http.set_debug_output(Config.instance.debug_logger) if Config.instance.debug_logger
          if @timber_scheme == 'https'
            http.use_ssl = true
            # Verification on Windows fails despite having a valid certificate.
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          http.read_timeout = 30
          http.ssl_timeout = 10
          http.open_timeout = 10
          http
        end

        # Creates a loop that processes the `@request_queue` on an interval.
        def request_outlet
          loop do
            http = build_http

            begin
              Timber::Config.instance.debug { "Starting HTTP connection" }

              http.start do |conn|
                deliver_requests(conn)
              end
            rescue => e
              Timber::Config.instance.debug { "#request_outlet error: #{e.message}" }
            ensure
              Timber::Config.instance.debug { "Finishing HTTP connection" }
              http.finish if http.started?
            end
          end
        end

        # Creates a loop that delivers requests over an open (kept alive) HTTP connection.
        # If the connection dies, the request is thrown back onto the queue and
        # the method returns. It is the responsibility of the caller to implement retries
        # and establish a new connection.
        def deliver_requests(conn)
          num_reqs = 0

          while num_reqs < @requests_per_conn
            if @request_queue.size > 0
              Timber::Config.instance.debug { "Waiting on next request, threads waiting: #{@request_queue.size}" }
            end

            request_attempt = @request_queue.deq

            if request_attempt.nil?
              sleep(1)
            else
              request_attempt.attempted!
              @requests_in_flight += 1

              begin
                resp = conn.request(request_attempt.request)
              rescue => e
                Timber::Config.instance.debug { "#deliver_requests error: #{e.message}" }

                # Throw the request back on the queue for a retry if it has been attempted less
                # than 3 times
                if request_attempt.attempts < 3
                  Timber::Config.instance.debug { "Request is being retried, #{request_attempt.attempts} previous attempts" }
                  @request_queue.enq(request_attempt)
                else
                  Timber::Config.instance.debug { "Request is being dropped, #{request_attempt.attempts} previous attempts" }
                end

                return false
              ensure
                @requests_in_flight -= 1
              end

              num_reqs += 1

              @last_resp = resp

              Timber::Config.instance.debug do
                if resp.code == "202"
                  "Logs successfully sent! View your logs at https://app.timber.io"
                else
                  "Log delivery failed! status: #{resp.code}, body: #{resp.body}"
                end
              end
            end
          end

          true
        end

        # Builds the `Authorization` header value for HTTP delivery to the Timber API.
        def authorization_payload
          @authorization_payload ||= if @source_id.nil?
            "Basic #{Base64.urlsafe_encode64(@api_key).chomp}"
          else
            "Bearer #{@api_key}"
          end
        end
    end
  end
end
