require "action_controller"

module Timber
  module Frameworks
    module Rails
      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        initializer(:timber_logger, before: :initialize_logger) do
          Rails.configure_middlewares(config.app_middleware)
          Integrations.integrate!

          # We set a default logger because Rails tries to write to a file by default.
          # This causes errors on paltforms with a readon only file system (Heroku)
          # Moreover, the Timber logger gets configured properly later in an initiailizer.
          # This is a hold over until we reach that file in the initialization process.
          logger = if defined?(::ActiveSupport::Logger)
            ::ActiveSupport::Logger.new(STDOUT)
          else
            ::Logger.new(STDOUT)
          end
          Rails.set_logger(logger)
        end
      end

      def self.set_logger(logger)
        if defined?(::ActiveSupport::TaggedLogging) && !logger.is_a?(::ActiveSupport::TaggedLogging)
          logger = ::ActiveSupport::TaggedLogging.new(logger)
        end

        Config.instance.logger = logger
        ::ActionController::Base.logger = logger
        ::ActionView::Base.logger = logger if ::ActionView::Base.respond_to?(:logger=)
        ::ActiveRecord::Base.logger = logger
        ::Rails.logger = logger
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