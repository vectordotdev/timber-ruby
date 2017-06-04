begin
  require "lograge"
rescue Exception
end

require "timber/cli/config_file"
require "timber/cli/installer"
require "timber/cli/io/messages"

module Timber
  class CLI
    module Installers
      class ConfigFile < Installer
        def run(app, path)
          config_file = Timber::CLI::ConfigFile.new(path)

          if config_file.exists?
            io.puts ""
            io.task_complete("#{config_file.path} already created")
            return true
          end

          if logrageify?
            config_file.logrageify!
          end

          io.puts ""
          task_message = "Creating #{config_file.path}"
          io.task(task_message) { config_file.create! }
        end

        private
          def logrageify?
            if defined?(::Lograge)
              io.puts ""
              io.puts IO::Messages.separator
              io.puts ""
              io.puts "We noticed you have lograge installed. Would you like to configure "
              io.puts "Timber to function similarly?"
              io.puts "(This silences template renders, sql queries, and controller calls."
              io.puts "You can always do this later in config/initialzers/timber.rb)"
              io.puts ""
              io.puts "y) Yes, configure Timber like lograge", :blue
              io.puts "n) No, use the Rails logging defaults", :blue
              io.puts ""

              case io.ask_yes_no("Enter your choice:", event_prompt: "Logrageify?")
              when :yes
                true
              when :no
                false
              end
            else
              false
            end
          end
      end
    end
  end
end