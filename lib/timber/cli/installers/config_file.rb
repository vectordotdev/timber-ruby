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
          config_file = Timber::CLI::ConfigFile.new(path, file_helper)

          if config_file.exists?
            io.puts ""
            io.task_complete("#{config_file.path} already created")
            return true
          end

          if logrageify?
            config_file.logrageify!
          elsif silence_template_renders?
            config_file.silence_template_renders!
          end

          io.puts ""
          task_message = "Creating #{config_file.path}"
          io.task(task_message) { config_file.create! }
        end

        private
          def logrageify?
            if lograge?
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

          def lograge?
            require "lograge"
            true
          rescue Exception
            false
          end

          def silence_template_renders?
            if action_view?
              io.puts ""
              io.puts IO::Messages.separator
              io.puts ""
              io.puts "Would you like to silence template render logs?"
              io.puts "(We've founds this to be of low value in production environments."
              io.puts "You can always adjust this later in config/initialzers/timber.rb)"
              io.puts ""
              io.puts "y) Yes, silence template renders", :blue
              io.puts "n) No, use the Rails logging defaults", :blue
              io.puts ""

              case io.ask_yes_no("Enter your choice:", event_prompt: "Silence template renders?")
              when :yes
                true
              when :no
                false
              end
            else
              false
            end
          end

          def action_view?
            require("action_view")
            true
          rescue Exception
            false
          end
      end
    end
  end
end