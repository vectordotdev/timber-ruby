module Timber
  class LogLine
    include Patterns::ToJSON
    include Patterns::ToLogfmt

    # Raised when there is an issue with the message being passed.
    # Note: this is handled in Logger
    class InvalidMessageError < ArgumentError; end

    attr_reader :context_snapshot, :dt, :line_indexes, :message

    def initialize(message)
      puts message.inspect
      @dt = Time.now.utc # Capture the time as soon as possible
      message = message.to_s # TODO: handle converting objects to json or kv?
      if message.bytesize > APISettings::MESSAGE_BYTE_SIZE_MAX
        raise InvalidMessageError.new("the log message must not exceed " +
          "#{APISettings::MESSAGE_BYTE_SIZE_MAX} bytes")
      end
      @message = message
      CurrentLineIndexes.log_line_added(self) # Bump the indexes
      @context_snapshot = CurrentContext.snapshot
    end

    def formatted_dt
      @formatted_dt ||= Macros::DateFormatter.format(dt)
    end

    private
      def json_payload
        @json_payload ||= {:dt => formatted_dt, :message => message}.merge(context_snapshot.as_json)
      end
  end
end
