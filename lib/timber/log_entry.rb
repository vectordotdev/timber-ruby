module Timber
  class LogEntry
    DT_PRECISION = 6.freeze
    SEVERITY_MAP = {
      ::Logger::Severity::DEBUG => :debug,
      ::Logger::Severity::INFO => :info,
      ::Logger::Severity::WARN => :warn,
      ::Logger::Severity::ERROR => :error,
      ::Logger::Severity::FATAL => :fatal,
      ::Logger::Severity::UNKNOWN => :unknown
    }

    # Creates a log entry suitable to be sent to the Timber API.
    # @param severity [Integer] the log level / severity
    # @param time [Time] the exact time the log message was written
    # @param progname [String] the progname scope for the log message
    # @param message [#to_json] structured data representing the log line event, this can
    #   be anything that responds to #to_json
    # @return [LogEntry] the resulting LogEntry object
    def initialize(level, time, progname, message, context, event)
      @level = level
      @time = time
      @progname = progname
      @message = message
      @context = context
      @event = event
    end

    def as_json(opts = {})
      hash = {level: level, dt: formatted_dt, message: message, context: context, event: event}

      if opts[:only]
        hash.select do |key, _value|
          opts[:only].include?(key)
        end
      else
        hash
      end
    end

    private
      def formatted_dt
        @formatted_dt ||= time.iso8601(DT_PRECISION)
      end
  end
end