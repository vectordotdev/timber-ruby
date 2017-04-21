module Timber
  module Frameworks
    # Module for Rails specific code, such as the Railtie and any methods that assist
    # with Rails setup.
    module Rails
      # Because of the crazy way Rails sorts it's initializers, it is
      # impossible for Timber to be inserted after Devise's omnitauth
      # middlewares.
      # See: https://github.com/plataformatec/devise/blob/master/lib/devise/rails.rb#L22
      # As such, we take a brute force approach here, ensuring we are inserted last
      # no matter what. This ensures that we come after authentication so that we can
      # properly set the user context.
      #
      # @private
      module MiddlewareStackProxyFix
        def self.included(klass)
          klass.class_eval do
            attr_accessor :timber_operations

            alias old_merge_into merge_into

            begin
              alias old_plus +
            rescue NameError
            end

            def +(*args)
              result = old_plus(*args)
              result.timber_operations = timber_operations
              result
            end

            def merge_into(*args)
              if timber_operations
                @operations -= timber_operations
                @operations += timber_operations
              end
              old_merge_into(*args)
            end
          end
        end
      end

      ::Rails::Configuration::MiddlewareStackProxy.send(:include, MiddlewareStackProxyFix)

      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        # Initialize Timber immediately after the logger in case anything uses the logger
        # during the initialization process.
        initializer(:timber, after: :initialize_logger) do
          logger = Rails.ensure_timber_logger(::Rails.logger)
          Rails.set_logger(logger)

          Integrations.integrate!
        end

        # Ensures that we insert the middlewares last. We need to insert these last
        # because initializers, such as Omniauth, insert middleware. If we are not
        # after these initializers we will not capture user context, for example.
        initializer(:timber_middlewares, after: :load_config_initializers, before: :build_middleware_stack) do
          timber_operations = Integrations::Rack.middlewares.collect do |middleware_class|
            [:use, [middleware_class], nil]
          end

          config.app_middleware.timber_operations = timber_operations
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
    end
  end
end