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

    def log_line_hashes_copy(&block)
      SEMAPHORE.synchronize do
        # Copy the array structure so we aren't dealing with
        # a changing array
        Array.new(self.log_line_hashes)
      end
    end

    private
      def log_line_hashes
        @log_line_hashes ||= []
      end
  end
end
