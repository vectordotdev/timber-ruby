require "uri"
require "net/http"
require "net/https"

module Timber
  class LogTruck
    class Delivery
      SUCCESS_CODE = "202".freeze
      READ_TIMEOUT = 15.freeze # seconds
      API_URI = URI.parse("https://timber-odin.herokuapp.com/agent_log_frames")
      HTTPS = Net::HTTP.new(API_URI.host, API_URI.port).tap do |https|
        https.use_ssl = true
        https.read_timeout = READ_TIMEOUT
      end
      CONTENT_TYPE = 'application/json'.freeze

      class DeliveryError < StandardError; end
      class NoApplicationSlugError < StandardError; end
      class NoApplicationKeyError < StandardError; end

      attr_reader :log_line_hashes

      def initialize(log_line_hashes)
        @log_line_hashes = log_line_hashes
      end

      def deliver!
        Config.logger.debug("Attempting delivery of:\n\n#{body_json}")
        https.request(new_request).tap do |res|
          if res.code.to_s != SUCCESS_CODE
            raise DeliveryError.new("Bad response from Timber API - #{res.code}: #{res.body}")
          end
        end
      rescue Exception => e
        # Ensure that we are always returning a consistent error.
        # This ensures we handle it appropriately and don't kill the
        # thread above.
        Config.logger.warn(e)
        raise DeliveryError.new(e.to_s)
      end

      private
        def https
          @https ||= HTTPS
        end

        def new_request
          Net::HTTP::Post.new(API_URI.request_uri).tap do |req|
            req['Content-Type'] = CONTENT_TYPE
            req['Authorization'] = authorization_payload
            req.body = body_json
          end
        end

        def body_hash
          {
            :agent_log_frame => {
              :log_lines => log_line_hashes
            }
          }
        end

        def body_json
          body_hash.to_json
        end

        def application_key
          Config.application_key || raise(NoApplicationKeyError.new)
        end

        def authorization_payload
          "Basic #{application_key}"
        end
    end
  end
end