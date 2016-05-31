module Timber
  class LogLine
    DATE_TIME_FORMAT = "%FT%T.%6N%:z".freeze

    attr_reader :context_json, :dt, :message

    def initialize(message)
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
        @formatted_dt ||= dt.strftime(DATE_TIME_FORMAT)
      end
  end
end
