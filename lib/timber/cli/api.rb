require "base64"
require "json"
require "net/https"
require "securerandom"
require "uri"

module Timber
  class CLI
    class API
      class APIKeyInvalidError < StandardError
        def message
          "Uh oh! The API key supplied is invalid. Please ensure that you copied the" \
            " key properly.\n\n#{Messages.obtain_key_instructions}"
        end
      end

      class NoAPIKeyError < StandardError
        def message
          "Uh oh! You didn't supply an API key.\n\n#{Messages.obtain_key_instructions}"
        end
      end

      TIMBER_API_URI = URI.parse('https://api.timber.io')
      APPLICATION_PATH = "/installer/application".freeze
      EVENT_PATH = "/installer/events".freeze
      HAS_LOGS_PATH = "/installer/has_logs".freeze
      USER_AGENT = "Timber Ruby/#{Timber::VERSION} (HTTP)".freeze

      def initialize(api_key)
        @api_key = api_key
        @session_id = SecureRandom.uuid
      end

      def application!
        get!(APPLICATION_PATH)
      end

      def event!(name, data = {})
        post!(EVENT_PATH, event: {name: name, data: data})
      end

      def wait_for_logs(iteration = 0, &block)
        if block_given?
          yield iteration
        end

        sleep 0.5

        res = get!(HAS_LOGS_PATH)

        case res.code
        when "202"
          wait_for_logs(iteration + 1, &block)

        when "204"
          true
        end
      end

      private
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
          req['Authorization'] = "Basic #{encoded_api_key}"
          req['User-Agent'] = USER_AGENT
          req['X-Installer-Session-Id'] = @session_id
          res = http.start do |http|
            http.request(req)
          end

          if res.code == "401"
            raise NoAPIKeyError.new
          elsif res.code == "403"
            raise APIKeyInvalidError.new
          else
            res
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