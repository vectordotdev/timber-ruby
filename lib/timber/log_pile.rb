require "thread"

module Timber
  # This is a thread safe queue for transporting logs to the Timber API.
  # TODO: Have these log lines persist to a file where
  #       a daemon can pick them up.
  class LogPile
    include Patterns::DelegatedSingleton

    SEMAPHORE = Mutex.new

    def drop_message(message)
      log_line = LogLine.new(message)
      drop(log_line)
    rescue LogLine::InvalidMessageError => e
      # Ignore the error and log it.
      Config.logger.error(e)
    rescue Exception => e
      # Fail safe to ensure the Timber gem never fails the app.
      Config.logger.exception(e)
    end

    def drop(log_line)
      SEMAPHORE.synchronize do
        log_lines << log_line
      end
    end

    def empty(&block)
      if log_lines.any?
        copy = log_lines_copy
        yield(copy) if block_given?
        remove(copy)
        self
      end
    end

    def size
      log_lines.size
    end

    private
      def remove(log_lines_copy)
        SEMAPHORE.synchronize do
          # Delete items by object_id since we are working
          # with the same object. Do not use equality here.
          log_lines_copy.each do |l1|
            log_lines.delete_if { |l2| l2.object_id == l1.object_id }
          end
        end
      end

      def log_lines_copy
        SEMAPHORE.synchronize do
          # Copy the array structure so we aren't dealing with
          # a changing array, but do not copy the items.
          log_lines.clone
        end
      end

      def log_lines
        @log_lines ||= []
      end
  end
end
