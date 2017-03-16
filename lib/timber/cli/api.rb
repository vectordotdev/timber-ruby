require "base64"
require "net/https"
require "uri"

module Timber
  class CLI
    class API
      class APIKeyInvalidError < StandardError
        def message
          "Uh oh! The API key supplied is invalid. Please ensure that you copied the" \
            " key properly.\n\n" \
            "Don't have a key? Head over to:\n" \
            "https://app.timber.io\n\n" \
            "Once there, create an application. Your API key will be displayed afterwards."
        end
      end

      class NoAPIKeyError < StandardError
        def message
          "Uh oh! You didn't supply an API key.\n\n" \
            "Don't have a key? Head over to:\n" \
            "https://app.timber.io\n\n" \
            "Once there, create an application. Your API key will be displayed afterwards."
        end
      end

      TIMBER_API_URI = URI.parse('https://api.timber.io')

      attr_reader :api_key

      def initialize(api_key)
        @api_key = api_key
      end

      def get!(path)
        req = Net::HTTP::Get.new(path)
        issue!(req)
      end

      private
        def issue!(req)
          req['Authorization'] = "Basic #{encoded_api_key}"
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
          Base64.urlsafe_encode64(api_key).chomp
        end
    end
  end
end