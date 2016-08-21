module Timber
  class LogDevice
    module Formatter
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

      def self.format(*args)
        text = args.pop
        codes = args.collect do |arg|
          if arg.is_a?(Symbol)
            const_get(arg.to_s.upcase)
          else
            arg
          end
        end
        "#{codes.join}#{text}#{CLEAR}"
      end
    end
  end
end