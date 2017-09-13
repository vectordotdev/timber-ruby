module Timber
  module LogDevices
    class HTTP
      # A simple thread-safe queue implementation that provides a #flush method.
      # The built-in ruby `Queue` class does not provide a #flush method that allows
      # the caller to retrieve all items on the queue in one call. The Ruby `SizedQueue` also
      # implements thread waiting, which is something we want to avoid. To keep things
      # simple and straight-forward, we designed this queue class.
      # @private
      class FlushableDroppingSizedQueue
        def initialize(max_size)
          @lock = Mutex.new
          @max_size = max_size
          @array = []
        end

        # Adds a message to the queue
        def enq(msg)
          @lock.synchronize do
            if !full?
              @array << msg
            end
          end
        end

        # Removes a single item from the queue
        def deq
          @lock.synchronize do
            @array.pop
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