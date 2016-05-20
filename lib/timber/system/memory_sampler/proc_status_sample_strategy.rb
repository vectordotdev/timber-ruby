module Timber
  module System
    class MemorySampler
      class ProcStatusSampleStrategy < SampleStrategy
        class NoRSSError < StandardError; end

        def bytes
          if proc_status =~ /RSS:\s*(\d+) kB/i
            $1.to_f / 1024.0
          else
            raise NoRSSError.new
          end
        end

        private
          def proc_status
            @proc_status ||= File.open(proc_status_file, "r") { |f| f.read_nonblock(4096).strip }
          end

          def proc_status_file_path
            @proc_status_file_path ||= "/proc/#{$$}/status"
          end
      end
    end
  end
end
