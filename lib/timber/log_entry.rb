module Timber
  # Represents a new log entry into the log. This is an intermediary class between
  # `Logger` and the log device that you set it up with.
  class LogEntry #:nodoc:
    DT_PRECISION = 6.freeze

    attr_reader :level, :time, :progname, :message, :context, :event

    # Creates a log entry suitable to be sent to the Timber API.
    # @param severity [Integer] the log level / severity
    # @param time [Time] the exact time the log message was written
    # @param progname [String] the progname scope for the log message
    # @param message [#to_json] structured data representing the log line event, this can
    #   be anything that responds to #to_json
    # @return [LogEntry] the resulting LogEntry object
    def initialize(level, time, progname, message, context, event)
      @level = level
      @time = time.utc
      @progname = progname
      @message = message
      @context = context
      @event = event
    end

    def as_json(options = {})
      options ||= {}
      hash = {level: level, dt: formatted_dt, message: message}

      if !event.nil?
        hash[:event] = event
      end

      if !context.nil? && context.length > 0
        hash[:context] = context
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