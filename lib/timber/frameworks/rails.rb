module Timber
  module Frameworks
    module Rails
      class StdoutLogger < ::ActiveSupport::Logger
        include ::LoggerSilence if defined?(::LoggerSilence)
      end

      def self.build_logger
        ::ActiveSupport::TaggedLogging.new(Logger.new).tap do |logger|
          if also_log_to_stdout?
            logger.extend ::ActiveSupport::Logger.broadcast(StdoutLogger.new(STDOUT))
          end
        end
      end

      private
        def self.also_log_to_stdout?
          !ENV["RAILS_LOG_TO_STDOUT"].nil? || !ENV["DYNO"].nil? || defined?(::RailsStdoutLogging)
        end

      class Railtie < ::Rails::Railtie
        config.timber = Config.instance
        config.before_initialize do
          ::Rails.logger = config.logger = Rails.build_logger
          Bootstrap.bootstrap!(config.app_middleware, ::Rails::Rack::Logger)
        end
      end
    end
  end
end
