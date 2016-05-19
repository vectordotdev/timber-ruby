module Timber
  class LogLine
    def initialize(message)
      @time = Time.now.utc
      @message = message
      # memory usage
      #
    end

    def to_json
    end
  end
end
