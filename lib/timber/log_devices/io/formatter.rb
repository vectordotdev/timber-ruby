module Timber
  module LogDevices
    class IO < LogDevice
      class Formatter
        # Embed in a String to clear all previous ANSI sequences.
        CLEAR   = "\e[0m"
        BOLD    = "\e[1m"

        # Colors
        BLACK   = "\e[30m"
        RED     = "\e[31m"
        GREEN   = "\e[32m"
        YELLOW  = "\e[33m"
        BLUE    = "\e[34m"
        MAGENTA = "\e[35m"
        CYAN    = "\e[36m"
        WHITE   = "\e[37m"

        def initialize(options = {})
          @ansi_format = options.key?(:ansi_format) ? options[:ansi_format] == true : true
        end

        def ansi_format?
          @ansi_format == true
        end

        def format(log_line)
          raise NotImplementedError.new("#format is not implemented")
        end

        private
          def ansi_format(*args)
            text = args.pop
            return text unless ansi_format?
            "#{args.join}#{text}#{CLEAR}"
          end
      end
    end
  end
end