module Timber
  module Frameworks
    module Rails
      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        initializer(:timber_silence_logger_complaints, before: :initialize_logger) do
          # We set a default logger because Rails tries to write to a file by default.
          # This causes errors on platforms with a read only file system (Heroku).
          # See this commit: https://github.com/heroku/rails_stdout_logging/commit/13d092650118bcfeb30f383d3274cee46cbf7b8f
          # Moreover, the Timber logger gets configured properly later in an initiailizer.
          # This is a hold over until we reach that file in the initialization process.
          is_heroku = !ENV['DYNO'].nil?
          if is_heroku
            logger = defined?(::ActiveSupport::Logger) ?
              ::ActiveSupport::Logger.new(STDOUT) : ::Logger.new(STDOUT)
            ::Rails.logger = config.logger = logger
          end
        end

        # Initialize Timber immediately after the logger in case anything uses the logger
        # during the initialization process.
        initializer(:timber, after: :initialize_logger) do
          # The goals here:
          # 1. Respect the default log device that rails sets in :initialize_logger
          # 2. Replace the logger with Timber::Logger so that users get our logger API
          # 3. Disable metadata so that the logger is essentially transparent until further
          #    configuration in initializers/timber.rb. This allows them to essentially "turn on"
          #    timber for production, staging, etc.
          log_device = ::Rails.logger.instance_variable_get(:@logdev).dev
          logger = Logger.new(log_device)
          logger.formatter = Logger::SimpleFormatter.new
          logger.level = ::Rails.logger.level
          Rails.set_logger(logger)

          Rails.configure_middlewares(config.app_middleware)
          Integrations.integrate!
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