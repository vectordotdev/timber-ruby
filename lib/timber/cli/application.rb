require "json"

module Timber
  class CLI
    class Application

      attr_reader :api_key, :environment, :framework_type, :heroku_drain_url, :language_type,
        :name, :platform_type

      def initialize(api)
        res = api.application!
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
    end
  end
end