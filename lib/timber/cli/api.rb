require "base64"
require "json"
require "net/https"
require "securerandom"
require "uri"

require "timber/cli/api/application"
require "timber/cli/io/messages"
require "timber/version"

module Timber
  class CLI
    # The API class provides an interface for all Timber API requests, parsing response
    # and returning the appropriate objects.
    class API

      # Raise when the API key provided is invalid.
      class APIKeyInvalidError < StandardError
        def message
          "Uh oh! The API key supplied is invalid. Please ensure that you copied the \n" \
            "key properly.\n\n#{IO::Messages.obtain_key_instructions}"
        end
      end

      class LogsNotReceivedError< StandardError
        def message
          "Bummer, we couldn't confirm log delivery with the Timber API, something is off. " \
            "If you email support@timber.io, we'll work with you to figure out what's going on. " \
            "And as a thank you sticking with us, we'll set you up with a 25% indefinite discount."
        end
      end

      # Raised when Timber is returning 500s
      class ServerError < StandardError
        def message
          "Crap, it looks like the Timber API is returning 500s :/. In order to properly " \
            "install Timber and test integration we need the Timber API to work correctly. " \
            "Chances are we're aware of the issue and if you try again later the API should " \
            "be working. \n\n" \
            "Status updates: http://status.timber.io \n" \
            "Yell at us via email: support@timber.io \n"
        end
      end

      # Raised when the API returns a response that a particular method is not expecting.
      class UnrecognizedAPIResponse < StandardError
        def initialize(res)
          @res = res
        end

        def message
          "Uh oh, we received a response from the Timber API that was not recognized " \
            "(#{res.code}). We've been notified of the issue, but please feel free to " \
            "yell at us via email to make sure we're aware: support@timber.io"
        end
      end

      TIMBER_PRODUCTION_API_URL = "https://api.timber.io".freeze
      TIMBER_STAGING_API_URL = "https://api.timber-staging.io".freeze
      TIMBER_API_URL = ENV['TIMBER_STAGING'] ? TIMBER_STAGING_API_URL : TIMBER_PRODUCTION_API_URL
      TIMBER_API_URI = URI.parse(TIMBER_API_URL)
      APPLICATION_PATH = "/installer/application".freeze
      EVENT_PATH = "/installer/events".freeze
      HAS_LOGS_PATH = "/installer/has_logs".freeze
      USER_AGENT = "Timber Ruby/#{Timber::VERSION} (HTTP)".freeze

      attr_accessor :api_key

      def initialize(api_key)
        @api_key = api_key
        @session_id = SecureRandom.uuid
      end

      # Returns the application for the given API key.
      def application!
        res = get!(APPLICATION_PATH)
        build_application(res)
      end

      # Hits the API to clone the app for the provided API key to the specified environment.
      def clone_application!(environment)
        return nil
      end

      # Sends an event to Timber so that we can understand how the installer is performing
      # an ensure a top notch user experience. We do not raise here because it is not
      # critical for the install process.
      def event(name, data = {})
        post!(EVENT_PATH, event: {name: name, data: data})
        true
      rescue Exception
        false
      end

      # After test logs are sent to the Timber API this method waits for them to be
      # received. This is how we test integration.
      def wait_for_logs(iteration = 0, &block)
        if block_given?
          yield iteration
        end

        case iteration
        when 20
          event(:excessive_log_waiting)
        when 60
          raise LogsNotReceivedError.new
        end

        sleep 0.5

        res = get!(HAS_LOGS_PATH)

        case res.code
        when "202"
          wait_for_logs(iteration + 1, &block)
        when "204"
          true
        else
          raise UnrecognizedAPIResponse.new(res)
        end
      end

      private
        def build_application(res)
          parsed_body = JSON.parse(res.body)
          attributes = parsed_body.fetch("data")
          Application.new(attributes)
        end

        def get!(path)
          req = Net::HTTP::Get.new(path)
          issue!(req)
        end

        def post!(path, body)
          req = Net::HTTP::Post.new(path)
          req.body = body.to_json
          req['Content-Type'] = "application/json"
          issue!(req)
        end

        def issue!(req)
          if api_key
            req['Authorization'] = "Basic #{encoded_api_key}"
          end

          req['User-Agent'] = USER_AGENT
          req['X-Installer-Session-Id'] = @session_id
          res = http.start do |http|
            http.request(req)
          end

          code = Integer(res.code)

          if [401, 403].include?(code)
            raise APIKeyInvalidError.new
          elsif code >= 500
            raise ServerError.new
          else
            res
          end
        rescue OpenSSL::SSL::SSLError => _e
          if http.ssl_version != :TLSv1_2
            http.ssl_version = :TLSv1_2
            issue!(req)
          end
        end

        def http
          @http ||= begin
            http = Net::HTTP.new(TIMBER_API_URI.host, TIMBER_API_URI.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            http
          end
        end

        def encoded_api_key
          Base64.urlsafe_encode64(@api_key).chomp
        end
    end
  end
end