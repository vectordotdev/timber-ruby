require "thread"

module Timber
  # TODO: Have these log lines persist to a file where
  # a daemon can pick them up.
  class LogPile
    include Patterns::DelegatedSingleton

    SEMAPHORE = Mutex.new

    def drop(log_line)
      SEMAPHORE.synchronize do
        log_line_hashes << log_line.to_hash
      end
    end

    def empty(&block)
      if log_line_hashes.any?
        copy = log_line_hashes_copy
        yield(copy)
        remove(copy)
        self
      end
    end

    def size
      log_line_hashes.size
    end

    private
      def remove(log_line_hashes_copy)
        SEMAPHORE.synchronize do
          # Delete items by object_id since we are working
          # with the same object. Do not use equality here.
          log_line_hashes_copy.each do |l1|
            log_line_hashes.delete_if { |l2| l2.object_id == l1.object_id }
          end
        end
      end

      def log_line_hashes_copy
        SEMAPHORE.synchronize do
          # Copy the array structure so we aren't dealing with
          # a changing array, but do not copy the items.
          Array.new(log_line_hashes)
        end
      end

      def log_line_hashes
        @log_line_hashes ||= []
      end
  end
end
