module Timber
  # Allows us to prefix all logs with [Timber] without having to
  # rely on external dependencies. This is slightly different
  # in that we don't want to create an entirely new logger or modify
  # the logger they pass us. We only want to prefix logs in the context
  # of this library.
  class Logger
    TAG = "[Timber]"

    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def debug(message)
      Timber.ignore { logger.debug(format_message(message)) }
    end

    def error(message)
      Timber.ignore { logger.error(format_message(message)) }
    end

    def fatal(message)
      Timber.ignore { logger.fatal(format_message(message)) }
    end

    def info(message)
      Timber.ignore { logger.info(format_message(message)) }
    end

    def warn(message)
      Timber.ignore { logger.warn(format_message(message)) }
    end

    private
      def format_message(message)
        "#{TAG} #{message}"
      end
  end
end
