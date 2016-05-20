module Timber
  module System
    class MemorySample
      class Sampler
        class SamplerError < StandardError; end
        class SampleError < SamplerError; end

        def bytes!
          raise NotImplementedError.new
        end

        def bytes
          bytes!
        rescue Exception
          nil
        end
      end

      class JavaHeapSampler < Sampler
        def sample
          java.lang.Runtime.getRuntime.totalMemory / (1024 * 1024).to_f
        end
      end

      class ProcStatusSampler < Sampler
        class NoRSSError < SamplerError; end

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

      class PSSampler < Sampler
        class UnknownPlatformError < SamplerError; end

        def bytes
          process = $$
          `#{command} #{process}`.split("\n")[1].to_f / 1024.0
        end

        private
          def command
            @command ||= if Platform.linux?
              "ps -o rsz"
            elsif Platform.darwin9?
              "ps -o rsz"
            elsif Platform.darwin10plus?
              "ps -o rss"
            elsif Platform.freebsd?
              "ps -o rss"
            elsif Platform.solaris?
              "/usr/bin/ps -o rss -p"
            else
              raise UnknownPlatformError.new
            end
          end
      end

      def bytes
        @bytes ||= sampler.bytes
      end

      private
        def sampler
          @sampler ||= if jruby?
            JavaHeapSampler.new
          elsif Platform.linux?
            PSSampler.new
          end
        end

        def jruby?
          defined?(JRuby)
        end
    end
  end
end
