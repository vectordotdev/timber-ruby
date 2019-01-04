require "socket"
require "time"

require "timber/contexts"
require "timber/events"

module Timber
  # Represents a new log entry into the log. This is an intermediary class between
  # `Logger` and the log device that you set it up with.
  class LogEntry #:nodoc:
    BINARY_LIMIT_THRESHOLD = 1_000.freeze
    DT_PRECISION = 6.freeze
    MESSAGE_MAX_BYTES = 8192.freeze

    attr_reader :context_snapshot, :event, :level, :message, :progname, :tags, :time

    # Creates a log entry suitable to be sent to the Timber API.
    # @param level [Integer] the log level / severity
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
      @message = @message.byteslice(0, MESSAGE_MAX_BYTES)
      @tags = options[:tags]
      @context_snapshot = context_snapshot
      @event = event
    end

    # Builds a hash representation containing simple objects, suitable for serialization (JSON).
    def to_hash(options = {})
      options ||= {}
      hash = {
        :level => level,
        :dt => formatted_dt,
        :message => message
      }

      if !tags.nil? && tags.length > 0
        hash[:tags] = tags
      end

      if !event.nil?
        hash.merge!(event)
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

    def inspect
      to_s
    end

    def to_json(options = {})
      to_hash.to_json
    end

    def to_msgpack(*args)
      to_hash.to_msgpack(*args)
    end

    # This is used when LogEntry objects make it to a non-Timber logger.
    def to_s
      message + "\n"
    end

    private
      def formatted_dt
        @formatted_dt ||= time.iso8601(DT_PRECISION)
      end

      # Attempts to encode a non UTF-8 string into UTF-8, discarding invalid characters.
      # If it fails, a nil is returned.
      def encode_string(string)
        string.encode('UTF-8', {
          :invalid => :replace,
          :undef   => :replace,
          :replace => '?'
        })
      rescue Exception
        nil
      end
  end
end
