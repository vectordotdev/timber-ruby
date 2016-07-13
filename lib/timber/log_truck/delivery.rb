require "uri"
require "net/http"
require "net/https"

module Timber
  class LogTruck
    class Delivery
      class DeliveryError < StandardError; end
      class NoApplicationKeyError < StandardError; end

      API_URI = URI.parse("https://timber-odin.herokuapp.com/agent_log_frames")
      CONTENT_TYPE = 'application/json'.freeze
      READ_TIMEOUT = 35.freeze # seconds
      RETRY_BACKOFF = 5.freeze # seconds
      RETRY_COUNT = 3.freeze
      USER_AGENT = "Timber Ruby Gem/#{Timber::VERSION}".freeze

      HTTPS = Net::HTTP.new(API_URI.host, API_URI.port).tap do |https|
        https.use_ssl = true
        https.read_timeout = READ_TIMEOUT
      end

      attr_reader :log_lines

      def initialize(log_lines)
        @log_lines = log_lines
      end

      def deliver!(retry_count = 0)
        Config.logger.debug("Attempting delivery of: #{body_json}")
        request!
      # Catch them all because of all the unknown exceptions that can happen during
      # a http request.
      rescue Exception => e
        # Ensure that we are always returning a consistent error.
        # This ensures we handle it appropriately and don't kill the
        # thread above.
        Config.logger.warn("Failed delivery: #{e.message}")

        retry_count += 1
        if retry_count <= RETRY_COUNT
          backoff_seconds = retry_count * RETRY_BACKOFF
          Config.logger.warn("Backing off #{backoff} seconds")
          sleep backoff_seconds
          Config.logger.warn("Retrying, attempt #{retry_count}")
          deliver!(retry_count)
        else
          Config.logger.warn("Retry attempts exceeded, dropping logs")
          raise DeliveryError.new(e.message)
        end
      end

      private
        def https
          @https ||= HTTPS
        end

        def request!
          https.request(new_request).tap do |res|
            code = res.code.to_i
            if code < 200 || code >= 300
              raise DeliveryError.new("Bad response from Timber API - #{res.code}: #{res.body}")
            end
            Config.logger.debug("Success! #{code}: #{res.body}")
          end
        end

        def new_request
          Net::HTTP::Post.new(API_URI.request_uri).tap do |req|
            req['Authorization'] = authorization_payload
            req['Body-Checksum'] = body_checksum # the API checks for duplicate requests
            req['Content-Type'] = CONTENT_TYPE
            req['Log-Line-Count'] = log_lines.size # additional check to ensure the correct # of log lines were sent
            req['User-Agent'] = USER_AGENT
            req.body = body_json
          end
        end

        # Used by the API to check for duplicate requests.
        def body_checksum
          @body_checksum ||= Digest::MD5.hexdigest(body_json)
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
          last_index = log_lines.size - 1
          log_lines.each_with_index do |log_line, index|
            @log_lines_json += log_line.to_json
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
