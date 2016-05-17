module Timber
  class LogLine
    def initialize(message)
      @time = Time.now.utc
      @message = message
    end
  end
end
