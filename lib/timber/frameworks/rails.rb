module Timber
  module Frameworks
    module Rails
      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        # We add this before initialize_logger to avoid initializing the default
        # rails logger at all. This logger attempts to log to a file which can cause
        # issues on some systems.
        initializer(:timber_logger, before: :initialize_logger) do
          # The environment files have already been loaded. Timber configuration
          # could have been set in there and it should be respected.
          log_device = Config.instance.log_device
          logger = ::ActiveSupport::TaggedLogging.new(Logger.new(log_device))
          ::Rails.logger = config.logger = logger
        end

        config.after_initialize do
          # Check that the logger is set properly, if not, raise
          # re-apply the timber logger to rails in case they changed it

          Probes.insert!
          Rails.insert_middlewares(config.app_middleware)
        end
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