module Timber
  class LogLine
    DATE_TIME_FORMAT = "%FT%T.%6N%:z".freeze

    attr_reader :context, :dt, :message

    def initialize(message)
      @dt = Time.now.utc
      @message = message
      @context = CurrentContext.to_hash
    end

    def to_hash
      {
        :dt => formatted_dt,
        :message => message,
        :context => context
      }
    end

    def to_json
      to_hash.to_json
    end

    private
      def formatted_dt
        @formatted_dt ||= dt.strftime(DATE_TIME_FORMAT)
      end
  end
end
