module Timber
  module LogDevices
    class HTTP
      # @private
      class LogMsgQueue
        def initialize(max_size)
          @lock = Mutex.new
          @max_size = max_size
          @array = []
        end

        def enqueue(msg)
          @lock.synchronize do
            @array << msg
          end
        end

        def flush
          @lock.synchronize do
            old = @array
            @array = []
            return old
          end
        end

        def full?
          size >= @max_size
        end

        def size
          @array.size
        end
      end
    end
  end
end