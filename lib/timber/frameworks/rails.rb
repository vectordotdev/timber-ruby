module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance
        config.before_initialize do
          Probes.insert!(config.app_middleware, ::Rails::Rack::Logger)
        end
      end

      def self.base_logger(logdev)
        defined?(::ActiveSupport::Logger) ?
          ::ActiveSupport::Logger.new(logdev) :
          ::Logger.new(logdev)
      end

      def self.logger(logdev)
        defined?(::ActiveSupport::TaggedLogging) ?
          ::ActiveSupport::TaggedLogging.new(base_logger(logdev)) :
          base_logger(logdev)
      end
    end
  end
end