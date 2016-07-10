module Timber
  class LogLine
    # Raised when there is an issue with the message being passed.
    # Note: this is handled in LogDeviceInstaller
    class InvalidMessageError < ArgumentError; end

    attr_reader :context, :dt, :message

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
      # This code needs to be efficient, hence the use of clone.
      # We do not want to convery to json here as it's done inline.
      # Leave that to the background task.
      @context = CurrentContext.clone
    end

    def json
      return @json if defined?(@json)
      # Loglines are immutable, cache the json.
      # Also build the json as a string as it's better for performance.
      # This avoid converting hashes to json strings over and over.
      @json = <<-JSON
        {"dt":#{formatted_dt.to_json}, "message":#{message.to_json}, "context":#{context.json}}
      JSON
      @json.strip!
      @json
    end

    private
      def formatted_dt
        @formatted_dt ||= dt.send(APISettings::DATE_FORMAT, APISettings::DATE_FORMAT_PRECISION)
      end
  end
end
