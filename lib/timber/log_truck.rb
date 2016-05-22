module Timber
  # Temporary class for alpha / beta purposes.
  # Log lines will be written to a file where a daemon
  # will pick them up.
  class LogTruck
    THROTTLE_SECONDS = 3.freeze

    attr_reader :log_line_hashes

    class << self
      def start
        # Fork a process to monitor the log pile for delivery
        pid = Process.fork do
          loop do
            log_line_hashes = LogPile.log_line_hashes_copy
            if log_lines.any?
              new(log_line_hashes).deliver!
            end
            sleep THROTTLE_SECONDS
          end
        end

        # Don't wait for the process to finish
        Process.detach(pid)
      end
    end

    def initialize(log_line_hashes)
      @log_line_hashes = log_line_hashes
    end

    def deliver!
      # make http call
    end
  end
end
