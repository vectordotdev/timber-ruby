module Timber
  class CLI
    module IOHelper
      def ask(message, allowed_inputs, api)
        api.event!(:waiting_for_input, prompt: message)

        write message + " "
        input = gets.downcase

        api.event!(:received_input, prompt: message, value: input)

        if allowed_inputs.include?(input)
          input
        else
          puts "Woops! That's not a valid input. Please enter one of #{allowed_inputs}."
          ask(message, allowed_inputs, api)
        end
      end

      def ask_yes_no(message, api)
        case ask(message + " (y/n)", ["y", "n"], api)
        when "y"
          :yes
        when "n"
          :no
        end
      end

      def colorize(text, color)
        return text if Gem.win_platform?

        code =
          case color
          when :blue then 34
          when :red then 31
          when :green then 32
          when :yellow then 33
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