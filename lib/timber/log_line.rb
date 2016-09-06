module Timber
  class LogLine
    include Patterns::ToJSON
    include Patterns::ToLogfmt

    # Raised when there is an issue with the message being passed.
    # Note: this is handled in Logger
    class InvalidMessageError < ArgumentError; end

    attr_reader :context_snapshot, :dt, :line_indexes, :message

    def initialize(message)
      puts "\n\n#{message}\n#{caller.join("\n")}"
      @dt = Time.now.utc # Capture the time as soon as possible
      message = message.to_s
      if message.bytesize > APISettings::MESSAGE_BYTE_SIZE_MAX
        Config.logger.warn("Log line message is too long, truncating")
        message = message.byteslice(0, APISettings::MESSAGE_BYTE_SIZE_MAX)
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
