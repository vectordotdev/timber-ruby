require "json"

module Timber
  class CLI
    class Application
      APPLICATION_PATH = "/installer/application".freeze
      HAS_LOGS_PATH = "/installer/has_logs".freeze

      attr_reader :api_key, :environment, :framework_type, :heroku_drain_url, :language_type,
        :name, :platform_type

      def initialize(api_key)
        @api = API.new(api_key)
        res = @api.get!(APPLICATION_PATH)
        parsed_body = JSON.parse(res.body)
        application_data = parsed_body.fetch("data")
        @api_key = application_data.fetch("api_key")
        @environment = application_data.fetch("environment")
        @framework_type = application_data.fetch("framework_type")
        @heroku_drain_url = application_data.fetch("heroku_drain_url")
        @language_type = application_data.fetch("language_type")
        @name = application_data.fetch("name")
        @platform_type = application_data.fetch("platform_type")
      end

      def heroku?
        platform_type == "heroku"
      end

      def wait_for_logs(iteration = 0)
        if block_given?
          yield iteration
        end

        sleep 0.5

        res = @api.get!(HAS_LOGS_PATH)

        case res.code
        when "202"
          wait_for_logs(iteration + 1)

        when "204"
          true
        end
      end
    end
  end
end