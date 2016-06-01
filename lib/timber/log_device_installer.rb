module Timber
  class LogDeviceInstaller
    module Collector
      def write(*args)
        super.tap do
          unless Timber.ignoring?
            message = args.first
            log_line = LogLine.new(message)
            LogPile.drop(log_line)
          end
        end
      end
    end

    def self.install!(logger)
      new(logger).install!
    end

    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def logdev
      @logdev ||= logger.instance_variable_get(:@logdev)
    end

    def install!
      if logdev.nil?
        raise NoLogDeviceError.new
      end

      if !collector_included?
        logdev.extend(Collector)
      end
    end

    private
      def collector_included?
        included_modules.include?(Collector)
      end

      def included_modules
        @included_modules ||= (class << logdev; self; end).included_modules
      end
  end
end
