module Timber
  class LogLine
    include Patterns::ToJSON

    # Raised when there is an issue with the message being passed.
    # Note: this is handled in Logger
    class InvalidMessageError < ArgumentError; end

    attr_reader :context_snapshot, :dt, :line_indexes, :message

    def initialize(message)
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

    def to_logfmt(options = {})
      @to_logfmt ||= {}
      @to_logfmt[options] ||= "".tap do |string|
        filtered_json_payload = options[:except] ?
          Core::Rejecter.reject(base_json_payload, options[:except]) :
          base_json_payload
        string << Core::LogfmtEncoder.encode(filtered_json_payload)
        string << " "
        string << context_snapshot.to_logfmt(:except => options[:except_contexts])
      end
    end

    private
      def formatted_dt
        @formatted_dt ||= Core::DateFormatter.format(dt)
      end

      def base_json_payload
        @base_json_payload ||= {:dt => formatted_dt, :message => message}
      end

      def json_payload
        @json_payload ||= base_json_payload.merge(context_snapshot.as_json)
      end
  end
end
