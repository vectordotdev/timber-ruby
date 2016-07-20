module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance
        config.before_initialize do
          Bootstrap.bootstrap!(config.app_middleware, ::Rails::Rack::Logger)
        end
      end
    end
  end
end
