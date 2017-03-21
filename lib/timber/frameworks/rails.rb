module Timber
  module Frameworks
    module Rails
      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        # We add this before initialize_logger to avoid initializing the default
        # rails logger. In older rails versions, :initialize_logger attempts to
        # log to a file which can raise permissions errors on some systems.
        initializer(:timber_logger, before: :initialize_logger) do
          Rails.apply_logger(config)
        end

        # We setup timber after :load_config_initializers because clients can customize
        # timber in config/initializers/timber.rb. This enssure their configuration is
        # respected.
        initializer(:timber_setup, after: :load_config_initializers) do
          # Re-apply the logger to respect any configuration set
          Rails.apply_logger(config)
          Config.instance.delegate_logger_to { ::Rails.logger }
          Rails.configure_middlewares(config.app_middleware)
          Integrations.integrate!
        end
      end

      def self.apply_logger(config)
        ::Rails.logger = config.logger = Config.instance.logger
      end

      def self.configure_middlewares(middleware)
        var_name = :"@_timber_middlewares_inserted"
        return true if middleware.instance_variable_defined?(var_name) && middleware.instance_variable_get(var_name) == true

        # Rails uses a proxy :/, so we need to do this instance variable hack
        middleware.instance_variable_set(var_name, true)
        Integrations::Rack.middlewares.each do |middleware_class|
          middleware.use middleware_class
        end
      end
    end
  end
end