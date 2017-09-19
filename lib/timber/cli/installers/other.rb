require "timber/cli/installer"
require "timber/cli/io/messages"

module Timber
  class CLI
    module Installers
      class Other < Installer
        def run(app)
          case get_delivery_strategy(app)
          when :http
            api_key_storage_preference = get_api_key_storage_preference
            api_key_code = get_api_key_code(api_key_storage_preference)
            install_http(api_key_code)
          when :stdout
            install_stdout
          end

          ask_to_proceed
        end

        private
          def install_stdout
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""
            io.puts "To integrate Timber, simply use the Timber::Logger. Just set your"
            io.puts "global logger to something like this:"
            io.puts ""
            io.puts IO::ANSI.colorize("    LOGGER = Timber::Logger.new(STDOUT)", :blue)
            io.puts ""
            io.ask_to_proceed
          end

          def install_http(api_key_code)
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""
            io.puts "To integrate Timber, simply use the Timber::Logger. Just set your"
            io.puts "global logger to something like this:"
            io.puts ""
            io.puts IO::ANSI.colorize("    log_device = Timber::LogDevices::HTTP.new(#{api_key_code})", :blue)
            io.puts IO::ANSI.colorize("    LOGGER = Timber::Logger.new(log_device)", :blue)
            io.puts ""
            io.ask_to_proceed
          end

          def ask_to_proceed
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""
            io.puts "We're going to send a few test messages to ensure communication is working."
            io.puts ""
            io.ask_to_proceed
            io.puts ""
          end
      end
    end
  end
end