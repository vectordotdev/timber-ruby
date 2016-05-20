module Timber
  class LogLine
    def initialize(message)
      @time = Time.now.utc
      @message = message
      @memory_usage = System::MemorySample.new.bytes
    end

    def to_hash
      {
        :dt => "fdsfds",
        :message => message,
        :level => level,
        :context => CurrentContext.to_hash
      }
    end
  end
end
