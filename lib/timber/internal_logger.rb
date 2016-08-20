require "logger"

module Timber
  # Allows us to prefix all logs with [Timber] without having to
  # rely on external dependencies. This is slightly different
  # in that we don't want to create an entirely new logger or modify
  # the logger they pass us. We only want to prefix logs in the context
  # of this library.
  class InternalLogger < ::Logger
    class Formatter < ::Logger::Formatter
      TAG = "[Timber]"

      # This method is invoked when a log event occurs
      def call(severity, timestamp, progname, msg)
        "#{TAG} #{String === msg ? msg : msg.inspect}\n"
      end
    end

    def initialize(*args)
      super
      @formatter = Formatter.new
    end

    # This is a convenience method for logging exceptions. Also
    # allows us to build a notify hook for any exception that happen in
    # the Timber library. This is extremely important for quality control.
    def exception(exception)
      if !exception.is_a?(Exception)
        raise ArgumentError.new("#exception must take an Exception type")
      end
      # TODO: notify us that this exception happened
      error(exception)
    end
  end
end
