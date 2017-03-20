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
          Rails.insert_middlewares(config.app_middleware)
          Probes.insert!
        end
      end

      def self.apply_logger(config)
        # Respect config.timber.logger = with ||=
        Config.instance.logger ||= if defined?(::ActiveSupport::TaggedLogging)
          log_device = Config.instance.log_device
          logger = Logger.new(log_device)
          ::ActiveSupport::TaggedLogging.new(logger)
        else
          log_device = Config.instance.log_device
          Logger.new(log_device)
        end

        ::Rails.logger = config.logger = logger
      end

      def self.insert_middlewares(middleware)
        var_name = :"@_timber_middlewares_inserted"
        return true if middleware.instance_variable_defined?(var_name) && middleware.instance_variable_get(var_name) == true

        # Rails uses a proxy :/, so we need to do this instance variable hack
        middleware.instance_variable_set(var_name, true)
        RackMiddlewares.middlewares.each do |m|
          middleware.insert_before ::Rails::Rack::Logger, m
        end
      end
    end
  end
end