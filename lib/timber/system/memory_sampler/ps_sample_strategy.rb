module Timber
  module System
    class MemorySampler
      class PSSampleStrategy < SampleStrategy
        class UnknownPlatformError < StandardError; end

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
    end
  end
end
