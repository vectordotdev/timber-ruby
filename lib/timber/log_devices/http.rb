require "monitor"
require "msgpack"

module Timber
  module LogDevices
    # A log device that buffers and sends logs to the Timber API over HTTP in intervals. The buffer
    # uses MessagePack::Buffer, which is fast, efficient with memory, and reduces
    # the payload size sent to Timber.
    class HTTP
      class DeliveryError < StandardError; end

      API_URI = URI.parse("https://api.timber.io/http_frames")
      CONTENT_TYPE = "application/json".freeze
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

      DEFAULT_DELIVERY_FREQUENCY = 2.freeze

      # Instantiates a new HTTP log device.
      #
      # @param api_key [String] The API key provided to you after you add your application to
      #   [Timber](https://timber.io).
      # @param [Hash] options the options to create a HTTP log device with.
      # @option attributes [Symbol] :frequency_seconds (2) How often the client should
      #   attempt to deliver logs to the Timber API. The HTTP client buffers logs between calls.
      def initialize(api_key, options = {})
        @api_key = api_key
        @buffer = []
        @monitor = Monitor.new
        @delivery_thread = Thread.new do
          at_exit { deliver }
          loop do
            sleep options[:frequency_seconds] || DEFAULT_DELIVERY_FREQUENCY
            deliver
          end
        end
      end

      def write(msg)
        @monitor.synchronize {
          @buffer << msg
        }
      end

      def close
        @delivery_thread.kill
      end

      private
        def deliver
          body = @buffer.read

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
              raise DeliveryError.new("Bad response from Timber API - #{res.code}: #{res.body}")
            end
            Config.instance.logger.debug("Success! #{code}: #{res.body}")
          end

          @buffer.clear
        end

        def authorization_payload
          @authorization_payload ||= "Basic #{Base64.strict_encode64(@api_key).chomp}"
        end
    end
  end
end