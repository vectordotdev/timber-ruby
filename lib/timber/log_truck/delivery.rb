require "uri"
require "net/http"
require "net/https"

module Timber
  class LogTruck
    class Delivery
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

      attr_reader :log_line_jsons

      def initialize(log_line_jsons)
        @log_line_jsons = log_line_jsons
      end

      def deliver!
        Config.logger.debug("Attempting delivery of:\n\n#{body_json}")
        https.request(new_request).tap do |res|
          code = res.code.to_i
          if code < 200 || code >= 300
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

        def body_json
          return @body_json if defined?(@body_json)
          # Build the json as a string since it is more efficient.
          # We are also working with string upstream for the same reason.
          @body_json ||= <<-JSON
            {"agent_log_frame": {"log_lines": #{log_lines_json}}}
          JSON
          @body_json.strip!
          @body_json
        end

        def log_lines_json
          return @log_lines_json if defined?(@log_lines_json)
          @log_lines_json = "["
          last_index = log_line_jsons.size - 1
          log_line_jsons.each_with_index do |log_line_json, index|
            @log_lines_json += log_line_json
            @log_lines_json += ", " if index != last_index
          end
          @log_lines_json += "]"
        end

        def application_key
          @application_key ||= Config.application_key || raise(NoApplicationKeyError.new)
        end

        def authorization_payload
          @authorization_payload ||= "Basic #{application_key}"
        end
    end
  end
end
