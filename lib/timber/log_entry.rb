module Timber
  # Represents a new log entry into the log. This is an intermediary class between
  # `Logger` and the log device that you set it up with.
  class LogEntry #:nodoc:
    DT_PRECISION = 6.freeze

    attr_reader :level, :time, :progname, :message, :context_snapshot, :event

    # Creates a log entry suitable to be sent to the Timber API.
    # @param severity [Integer] the log level / severity
    # @param time [Time] the exact time the log message was written
    # @param progname [String] the progname scope for the log message
    # @param message [String] Human readable log message.
    # @param context_snapshot [Hash] structured data representing a snapshot of the context at
    #   the given point in time.
    # @param event [Timber.Event] structured data representing the log line event. This should be
    #   an instance of `Timber.Event`.
    # @return [LogEntry] the resulting LogEntry object
    def initialize(level, time, progname, message, context_snapshot, event)
      @level = level
      @time = time.utc
      @progname = progname
      @message = message
      @context_snapshot = context_snapshot
      @event = event
    end

    def as_json(options = {})
      options ||= {}
      hash = {level: level, dt: formatted_dt, message: message}

      if !event.nil?
        hash[:event] = event
      end

      if !context_snapshot.nil? && context_snapshot.length > 0
        hash[:context] = context_snapshot
      end

      if options[:only]
        hash.select do |key, _value|
          options[:only].include?(key)
        end
      elsif options[:except]
        hash.select do |key, _value|
          !options[:except].include?(key)
        end
      else
        hash
      end
    end

    def to_json(options = {})
      as_json(options).to_json
    end

    def to_msgpack(*args)
      as_json.to_msgpack(*args)
    end

    private
      def formatted_dt
        @formatted_dt ||= time.iso8601(DT_PRECISION)
      end
  end
end