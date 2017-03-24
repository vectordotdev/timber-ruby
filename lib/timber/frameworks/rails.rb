module Timber
  module Frameworks
    # Module for Rails specific code, such as the Railtie and any methods that assist
    # with Rails setup.
    module Rails
      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        # Initialize Timber immediately after the logger in case anything uses the logger
        # during the initialization process.
        initializer(:timber, group: :all, after: :initialize_logger) do
          logger = Rails.ensure_timber_logger(::Rails.logger)
          Rails.set_logger(logger)

          Rails.configure_middlewares(config.app_middleware)
          Integrations.integrate!
        end
      end

      # This builds a new Timber::Logger from an existing logger. This allows us to transparentl
      # switch users onto the Timber::Logger since we support a more useful logging API.
      def self.ensure_timber_logger(existing_logger)
        if existing_logger.is_a?(Logger)
          return existing_logger
        end

        log_device = existing_logger.instance_variable_get(:@logdev).try(:dev)
        logger = Logger.new(log_device)
        logger.level = existing_logger.try(:level) || Logger::DEBUG
        if defined?(::ActiveSupport::TaggedLogging)
          logger = ::ActiveSupport::TaggedLogging.new(logger)
        end
        logger
      end

      # Sets the Rails logger. Rails
      def self.set_logger(logger)
        if defined?(::ActiveSupport::TaggedLogging) && !logger.is_a?(::ActiveSupport::TaggedLogging)
          logger = ::ActiveSupport::TaggedLogging.new(logger)
        end

        Config.instance.logger = logger

        # Set the various Rails framework loggers. We *have* to do this because Rails
        # internally sets these with an ActiveSupport.onload(:active_record) { } callback.
        # We don't have an opportunity to intercept this since the :initialize_logger
        # initializer loads these modules. Moreover, earlier version of rails don't do this
        # at all, hence the defined? checks. Yay for being implicit.
        ::ActionCable::Server::Base.logger = logger if defined?(::ActionCable::Server::Base) && ::ActionCable::Server::Base.respond_to?(:logger=)
        ::ActionController::Base.logger = logger if defined?(::ActionController::Base) && ::ActionController::Base.respond_to?(:logger=)
        ::ActionMailer::Base.logger = logger if defined?(::ActionMailer::Base) && ::ActionMailer::Base.respond_to?(:logger=)
        ::ActionView::Base.logger = logger if defined?(::ActionView::Base) && ::ActionView::Base.respond_to?(:logger=)
        ::ActiveRecord::Base.logger = logger if defined?(::ActiveRecord::Base) && ::ActiveRecord::Base.respond_to?(:logger=)
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