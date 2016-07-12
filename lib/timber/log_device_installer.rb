module Timber
  # Takes a logger instance and extends the embedded
  # log device to listen for writes.
  # TODO: Should we extend the log device or just the logger?
  #       The main reason I extend the device is to handle puts.
  #       Unfortunately people use puts for logging in Heroku.
  class LogDeviceInstaller
    module Collector
      def write(*args)
        super.tap do
          begin
            unless Timber.ignoring?
              begin
                message = args.first
                log_line = LogLine.new(message)
                LogPile.drop(log_line)
              rescue LogLine::InvalidMessageError => e
                # Ignore the error and log it.
                Config.logger.error(e)
              end
            end
          rescue Exception => e
            # Fail safe to ensure the Timber gem never fails the app.
            Config.logger.exception(e)
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
