require "timber/cli/installer"
require "timber/cli/io/messages"

module Timber
  class CLI
    module Installers
      class Other < Installer
        def run(app)
          puts ""
          puts IO::Messages.separator
          puts ""

          if app.heroku?
            install_stdout
          else
            api_key_storage_preference = get_api_key_storage_preference
            api_key_code = get_api_key_code(api_key_storage_type)

            install_http(api_key_code)
          end
        end

        private
          def install_stdout
            puts ""
            puts IO::Messages.separator
            puts ""
            puts "To integrate Timber, we need to instantiate the logger. Your global"
            puts "logger should be set to something like this:"
            puts ""
            puts colorize("    LOGGER = Timber::Logger.new(STDOUT)", :blue)
          end

          def install_http(api_key_code)
            puts ""
            puts IO::Messages.separator
            puts ""
            puts "To integrate Timber, we need to instantiate the logger. Your global"
            puts "logger should be set to something like this:"
            puts ""
            puts colorize("    log_device = Timber::LogDevices::HTTP.new(#{api_key_code})", :blue)
            puts colorize("    LOGGER = Timber::Logger.new(log_device)", :blue)
          end
      end
    end
  end
end