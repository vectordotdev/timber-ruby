module Timber
  class LogLine
    # Raised when there is an issue with the message being passed.
    class InvalidMessageError < ArgumentError; end

    attr_reader :context_json, :dt, :message

    def initialize(message)
      # Not all objects will be a string.
      # TODO: handle converting objects to json or kv?
      message = message.to_s

      if !message.respond_to?(:bytesize)
        raise InvalidMessageError.new("the log message must respond to bytesize")
      end

      if message.bytesize > APISettings::MESSAGE_BYTE_SIZE_MAX
        raise InvalidMessageError.new("the log message must not exceed #{APISettings::MESSAGE_BYTE_SIZE_MAX} bytes")
      end

      @dt = Time.now.utc
      @message = message
      @context_json = CurrentContext.json
    end

    def json
      return @json if defined?(@json)
      # Loglines are immutable, cache the json.
      # Also build the json as a string as it's better for performance.
      # This avoid converting hashes to json strings over and over.
      @json = <<-JSON
        {"dt":#{formatted_dt.to_json}, "message":#{message.to_json}, "context":#{context_json}}
      JSON
      @json.strip!
      @json
    end

    private
      def formatted_dt
        # Note: very important that we keep the iso8601 format. Otherwise the Timber API
        # will recognized the date as invalid.
        @formatted_dt ||= dt.iso8601
      end
  end
end
