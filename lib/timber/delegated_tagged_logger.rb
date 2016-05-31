module Timber
  # Allows us to prefix all logs with [Timber] without having to
  # rely on external dependencies. This is slightly different
  # in that we don't want to create an entirely new logger or modify
  # the logger they pass us. We only want to prefix logs in the context
  # of this library.
  class DelegatedTaggedLogger
    TAG = "[Timber]"

    attr_reader :logger

    def initialize(logger)
      @logger = logger
    end

    def debug(message)
      logger.debug(format_message(message))
    end

    def error(message)
      logger.error(format_message(message))
    end

    def fatal(message)
      logger.fatal(format_message(message))
    end

    def info(message)
      logger.info(format_message(message))
    end

    def warn(message)
      logger.warn(format_message(message))
    end

    private
      def format_message(message)
        "#{TAG} #{message}"
      end

      def method_missing(name, *args, &block)
        logger.send(name, *args, &block)
      end
  end
end
