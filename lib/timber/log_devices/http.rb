module Timber
  module LogDevices
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
        https.keep_alive_timeout = 60
        https.open_timeout = 10
      end

      DEFAULT_DELIVERY_FREQUENCY = 2.freeze

      def initialize(api_key, options = {})
        @api_key = api_key
        @buffer = MessagePack::Buffer.new # faster and better memory management
        @delivery_thread = Thread.new do
          at_exit { deliver }
          loop do
            deliver
            sleep options[:delivery_frequency_seconds] || DEFAULT_DELIVERY_FREQUENCY
          end
        end
      end

      def write(msg)
        @buffer << msg
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
            Config.logger.debug("Success! #{code}: #{res.body}")
          end
        end
    end
  end
end