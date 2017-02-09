module Timber
  module Frameworks
    module Rails
      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance
        config.before_initialize do
          Probes.insert!()
          Rails.insert_middlewares(config.app_middleware)
        end
      end

      def self.insert_middlewares(middleware)
        var_name = :"@_timber_middlewares_inserted"
        return true if middleware.instance_variable_defined?(var_name) && middleware.instance_variable_get(var_name) == true
        # Rails uses a proxy :/, so we need to do this instance variable hack
        middleware.instance_variable_set(var_name, true)
        middleware.insert_before ::Rails::Rack::Logger, Middleware
      end
    end
  end
end