require 'socket'

require "timber/contexts"
require "timber/events"

module Timber
  # Represents a new log entry into the log. This is an intermediary class between
  # `Logger` and the log device that you set it up with.
  class LogEntry #:nodoc:
    DT_PRECISION = 6.freeze
    SCHEMA = "https://raw.githubusercontent.com/timberio/log-event-json-schema/v2.0.4/schema.json".freeze

    attr_reader :context_snapshot, :event, :level, :message, :progname, :tags, :time, :time_ms

    # Creates a log entry suitable to be sent to the Timber API.
    # @param severity [Integer] the log level / severity
    # @param time [Time] the exact time the log message was written
    # @param progname [String] the progname scope for the log message
    # @param message [String] Human readable log message.
    # @param context_snapshot [Hash] structured data representing a snapshot of the context at
    #   the given point in time.
    # @param event [Timber.Event] structured data representing the log line event. This should be
    #   an instance of {Timber.Event}.
    # @return [LogEntry] the resulting LogEntry object
    def initialize(level, time, progname, message, context_snapshot, event, options = {})
      @level = level
      @time = time.utc
      @progname = progname

      # If the message is not a string we call inspect to ensure it is a string.
      # This follows the default behavior set by ::Logger
      # See: https://github.com/ruby/ruby/blob/trunk/lib/logger.rb#L615
      @message = message.is_a?(String) ? message : message.inspect
      @tags = options[:tags]
      @time_ms = options[:time_ms]

      context_snapshot = {} if context_snapshot.nil?

      # Set the system context for each log entry since processes can be forked
      # and the process ID could change.
      hostname = Socket.gethostname
      pid = Process.pid
      system_context = Contexts::System.new(hostname: hostname, pid: pid)
      context_snapshot[system_context.keyspace] = system_context.as_json

      @context_snapshot = context_snapshot
      @event = event
    end

    def as_json(options = {})
      options ||= {}
      hash = {:level => level, :dt => formatted_dt, :message => message, :tags => tags,
        :time_ms => time_ms}

      if !event.nil?
        hash[:event] = event.as_json
      end

      if !context_snapshot.nil? && context_snapshot.length > 0
        hash[:context] = context_snapshot
      end

      hash[:"$schema"] = SCHEMA

      hash = if options[:only]
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

      Util::Hash.deep_compact(hash)
    end

    def inspect
      to_s
    end

    def to_json(options = {})
      as_json(options).to_json
    end

    def to_msgpack(*args)
      as_json.to_msgpack(*args)
    end

    # This is used when LogEntry objects make it to a non-Timber logger.
    def to_s
      log_message = message

      if !event.nil?
        event_hash = event.as_json
        event_type = event_hash.keys.first

        event_type = if event.is_a?(Events::Custom)
          "#{event_type}.#{event.type}"
        else
          "#{event_type}"
        end

        log_message = "#{message} [#{event_type}]"
      end

      log_message + "\n"
    end

    private
      def formatted_dt
        @formatted_dt ||= time.iso8601(DT_PRECISION)
      end
  end
end