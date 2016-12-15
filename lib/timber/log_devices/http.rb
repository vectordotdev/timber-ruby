require "timber/log_devices/http/triggered_buffer"

module Timber
  module LogDevices
    # A log device that buffers and delivers log messages to the Timber API in batches.
    # The payload is an array of msgpack formatter message delimited by new lines. Msgpack
    # is an efficient way to represent JSON objects that save on space.
    #
    # Delivery has 2 triggers: a payload limit and a frequency, both defined by
    # {PAYLOAD_LIMIT_BYTES} and {DELIVERY_FREQUENCY_SECONDS} respectively. If either are
    # surpassed, a delivery will be attempted.
    #
    # In the event that the HTTP requests cannot empty the buffer fast enough, a buffer overflow
    # will be triggered. This can be handled with the `:buffer_overflow_handler` option upon
    # instantiation, allowing you to write the data to disk, etc. See {#new} for more details.
    class HTTP
      API_URI = URI.parse("https://api.timber.io/http_frames")
      CONTENT_TYPE = "application/x-timber-msgpack-frame-1".freeze
      CONNECTION_HEADER = "keep-alive".freeze
      USER_AGENT = "Timber Ruby Gem/#{Timber::VERSION}".freeze
      HTTPS = Net::HTTP.new(API_URI.host, API_URI.port).tap do |https|
        https.use_ssl = true
        https.read_timeout = 30
        https.ssl_timeout = 10
        if https.respond_to?(:keep_alive_timeout=)
          https.keep_alive_timeout = 60
        end
        https.open_timeout = 10
      end
      DELIVERY_FREQUENCY_SECONDS = 2.freeze


      # Instantiates a new HTTP log device.
      #
      # @param api_key [String] The API key provided to you after you add your application to
      #   [Timber](https://timber.io).
      # @param [Hash] options the options to create a HTTP log device with.
      # @option attributes [Symbol] :frequency_seconds (2) How often the client should
      #   attempt to deliver logs to the Timber API. The HTTP client buffers logs between calls.
      def initialize(api_key, options = {})
        @api_key = api_key
        @buffer = TriggeredBuffer.new(
          payload_limit_bytes: options[:payload_limit_bytes],
          limit_bytes: options[:buffer_limit_bytes],
          overflow_handler: options[:buffer_overflow_handler]
        )
        @delivery_interval_thread = Thread.new do
          loop do
            sleep options[:frequency_seconds] || DELIVERY_FREQUENCY_SECONDS
            buffer_for_delivery = @buffer.reserve
            if buffer_for_delivery
              deliver(buffer_for_delivery)
            end
          end
        end
      end

      def write(msg)
        buffer_for_delivery = @buffer.write(msg)
        if buffer_for_delivery
          deliver(buffer_for_delivery)
        end
        true
      end

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
            request = Net::HTTP::Post.new(API_URI.request_uri).tap do |req|
              req['Authorization'] = authorization_payload
              req['Connection'] = CONNECTION_HEADER
              req['Content-Type'] = CONTENT_TYPE
              req['User-Agent'] = USER_AGENT
              req.body = body
            end

            HTTPS.request(request).tap do |res|
              code = res.code.to_i
              if code < 200 || code >= 300
                raise DeliveryError.new("Timber HTTP delivery failed - #{res.code}: #{res.body}")
              end
              @buffer.remove(body)
              Config.instance.logger.debug("Timber HTTP delivery successful - #{code}")
            end
          end
        end

        def authorization_payload
          @authorization_payload ||= "Basic #{Base64.strict_encode64(@api_key).chomp}"
        end
    end
  end
end