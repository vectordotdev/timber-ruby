require "timber/log_devices/http/triggered_buffer"

module Timber
  module LogDevices
    # A log device that buffers and delivers log messages over HTTPS to the Timber API in batches.
    # The buffer and delivery strategy are very efficient and the log messages will be delivered in
    # msgpack format.
    #
    # See {#initialize} for options and more details.
    class HTTP
      API_URI = URI.parse(ENV["TIMBER_INGESTION_URL"] || "https://logs.timber.io/frames")
      CONTENT_TYPE = "application/x-timber-msgpack-frame-1".freeze
      CONNECTION_HEADER = "keep-alive".freeze
      USER_AGENT = "Timber Ruby Gem/#{Timber::VERSION}".freeze
      HTTPS = Net::HTTP.new(API_URI.host, API_URI.port).tap do |https|
        https.use_ssl = true
        https.read_timeout = 30
        https.ssl_timeout = 10
        # Ruby 1.9.X doesn't have this setting.
        if https.respond_to?(:keep_alive_timeout=)
          https.keep_alive_timeout = 60
        end
        https.open_timeout = 10
      end
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
        @api_key = api_key
        @buffer = TriggeredBuffer.new(
          payload_limit_bytes: options[:payload_limit_bytes],
          limit_bytes: options[:buffer_limit_bytes],
          overflow_handler: options[:buffer_overflow_handler]
        )
        @delivery_interval_thread = Thread.new do
          loop do
            sleep(options[:delivery_frequency_seconds] || DELIVERY_FREQUENCY_SECONDS)

            @last_messages_overflow_count = 0
            messages_overflown_count = @buffer.messages_overflown_count
            if messages_overflown_count > @last_messages_overflow_count
              difference = messages_overflown_count - @last_messages_overflow_count
              @last_messages_overflow_count = messages_overflown_count
              logger.warn("Timber HTTP buffer has overflown #{difference} times")
            end

            buffer_for_delivery = @buffer.reserve
            if buffer_for_delivery
              deliver(buffer_for_delivery)
            end
          end
        end
      end

      # Write a new log line message to the buffer, and deliver if the msg exceeds the
      # payload limit.
      def write(msg)
        buffer_for_delivery = @buffer.write(msg)
        if buffer_for_delivery
          deliver(buffer_for_delivery)
        end
        true
      end

      # Closes the log device, cleans up, and attempts one last delivery.
      def close
        @delivery_interval_thread.kill
        buffer_for_delivery = @buffer.reserve
        if buffer_for_delivery
          deliver(buffer_for_delivery)
        end
      end

      private
        def deliver(body)
          Thread.new do
            RETRY_LIMIT.times do |try_index|
              request = Net::HTTP::Post.new(API_URI.request_uri).tap do |req|
                req['Authorization'] = authorization_payload
                req['Connection'] = CONNECTION_HEADER
                req['Content-Type'] = CONTENT_TYPE
                req['User-Agent'] = USER_AGENT
                req.body = body
              end

              res = HTTPS.request(request)
              code = res.code.to_i
              if code < 200 || code >= 300
                try = try_index + 1
                logger.debug("Timber HTTP delivery failed, try #{try} - #{res.code}: #{res.body}")
                sleep(try * BACKOFF_RATE_SECONDS)
              else
                @buffer.remove(body)
                logger.debug("Timber HTTP delivery successful - #{code}")
                logger.debug("Timber new buffer size - #{@buffer.total_bytesize}")
                break # exit the loop
              end
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