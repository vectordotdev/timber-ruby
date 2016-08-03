module Timber
  class LogLine
    # Raised when there is an issue with the message being passed.
    # Note: this is handled in Logger
    class InvalidMessageError < ArgumentError; end

    attr_reader :context_snapshot, :dt, :line_indexes, :message

    def initialize(message)
      # Capture the time as soon as possible
      @dt = Time.now.utc

      # Not all objects will be a string.
      # TODO: handle converting objects to json or kv?
      message = message.to_s

      if !message.respond_to?(:bytesize)
        raise InvalidMessageError.new("the log message must respond to bytesize")
      end

      if message.bytesize > APISettings::MESSAGE_BYTE_SIZE_MAX
        raise InvalidMessageError.new("the log message must not exceed #{APISettings::MESSAGE_BYTE_SIZE_MAX} bytes")
      end

      @message = message

      # Bump the indexes
      CurrentLineIndexes.log_line_added(self)

      # This code needs to be efficient, hence the use of snapshotting.
      # We do not want to convert to json here as it's done inline.
      # Leaving that to the background task.
      @context_snapshot = CurrentContext.snapshot
    end

    def as_json(*args)
      @as_json ||= {
        :dt      => formatted_dt,
        :message => message,
        :context => context_snapshot
      }
    end

    def to_json(*args)
      # Note: this is run in the background thread, hence the hash creation.
      @to_json ||= as_json.to_json(*args)
    end

    private
      def formatted_dt
        @formatted_dt ||= dt.send(APISettings::DATE_FORMAT, APISettings::DATE_FORMAT_PRECISION)
      end
  end
end
