module Timber
  module LogDevices
    class HTTP
      # A simple thread-safe queue implementation that provides a #flush method.
      # The built-in ruby Queue class does not provide a #flush method. It also
      # implement thread waiting which is something we do not want. To keep things
      # simple and straight-forward we designed our own simple queue class.
      # @private
      class FlushableSizedQueue
        def initialize(max_size)
          @lock = Mutex.new
          @max_size = max_size
          @array = []
        end

        # Adds a message to the queue
        def enqueue(msg)
          @lock.synchronize do
            @array << msg
          end
        end

        # Flushes all message from the queue and returns them.
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