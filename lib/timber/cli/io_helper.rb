module Timber
  class CLI
    module IOHelper
      def ask(message)
        write message + " "
        gets
      end

      def ask_yes_no(message)
        case ask(message + " (y/n)")
        when "y", "Y"
          :yes
        when "n", "N"
          :no
        else
          puts "Woops! That's not a valid input. Please try again."
          ask_yes_no(message)
        end
      end

      def colorize(text, color)
        return text if Gem.win_platform?

        code =
          case color
          when :red then 31
          when :green then 32
          else 0
          end

        "\e[#{code}m#{text}\e[0m"
      end

      def gets
        value = stdin.gets
        value ? value.chomp.downcase : ""
      end

      def puts(message)
        stdout.puts(message)
      end

      def write(message)
        stdout.write(message)
      end

      private
        def stdout
          $stdout
        end

        def stdin
          $stdin
        end
    end
  end
end