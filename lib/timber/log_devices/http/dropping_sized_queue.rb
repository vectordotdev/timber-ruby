module Timber
  module LogDevices
    class HTTP
      # Works like SizedQueue, but drops message instead of blocking. Pass one of these in
      # to {HTTP#intiialize} via the :request_queue option if you'd prefer to drop messages
      # in the event of a buffer overflow instead of applying back pressure.
      class DroppingSizedQueue < SizedQueue
        # Returns true/false depending on whether the queue is full or not
        def push(obj)
          @mutex.synchronize do
            return false unless @que.length < @max

            @que.push obj
            begin
              t = @waiting.shift
              t.wakeup if t
            rescue ThreadError
              retry
            end
            return true
          end
        end
      end
    end
  end
end