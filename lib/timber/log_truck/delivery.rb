require "uri"
require "net/http"
require "net/https"

module Timber
  class LogTruck
    class Delivery
      READ_TIMEOUT = 15.freeze # seconds
      API_URI = URI.parse("https://timber-odin.herokuapp.com/")
      HTTPS = Net::HTTP.new(API_URI.host, API_URI.port).tap do |https|
        https.use_ssl = true
        https.read_timeout = READ_TIMEOUT
      end
      CONTENT_TYPE = 'application/json'.freeze

      class DeliveryError < StandardError; end
      class NoApplicationIDError < StandardError; end
      class NoApplicationKeyError < StandardError; end

      attr_reader :log_line_hashes

      def initialize(log_line_hashes)
        @log_line_hashes = log_line_hashes
      end

      def deliver!
        https.request(new_request).tap do |res|
          if res.code.to_s != "200"
            raise DeliveryError.new("Bad response from Timber API - #{res.code}: #{res.body}")
          end
        end
      rescue Exception => e
        # Ensure that we are always returning a consistent error.
        # This ensures we handle it appropriately and don't kill the
        # thread above.
        raise DeliveryError.new(e.to_s)
      end

      private
        def https
          @https ||= HTTPS.tap do |https|
            https.set_debug_output(Config.logger)
          end
        end

        def new_request
          Net::HTTP::Post.new(API_URI.request_uri).tap do |req|
            req['Content-Type'] = CONTENT_TYPE
            req['Authorization'] = authorization_payload
            req.body = body
          end
        end

        def body
          log_line_hashes.to_json
        end

        def application_id
          Config.application_id || raise(NoApplicationIDError.new)
        end

        def application_key
          Config.application_key || raise(NoApplicationKeyError.new)
        end

        def authorization_payload
          "Basic #{application_id}:#{application_key}"
        end
    end
  end
end
