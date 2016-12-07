module Timber
  module Frameworks
    module Rails
      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance
        config.before_initialize do
          Probes.insert!(config.app_middleware, ::Rails::Rack::Logger)
        end
      end
    end
  end
end