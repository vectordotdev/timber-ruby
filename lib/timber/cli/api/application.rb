module Timber
  class CLI
    class API
      class Application
        DEVELOPMENT_ENVIRONMENT = "development".freeze
        TEST_ENVIRONMENT = "test".freeze
        HEROKU = "heroku".freeze

        attr_accessor :api_key, :environment, :heroku_drain_url,
          :name, :platform_type

        def initialize(attributes)
          @api_key = attributes.fetch("api_key")
          @environment = attributes.fetch("environment")
          @heroku_drain_url = attributes.fetch("heroku_drain_url")
          @name = attributes.fetch("name")
          @platform_type = attributes.fetch("platform_type")
        end

        def development?
          environment == DEVELOPMENT_ENVIRONMENT
        end

        def test?
          environment == TEST_ENVIRONMENT
        end

        def heroku?
          platform_type == HEROKU
        end
      end
    end
  end
end
