# encoding: utf-8

# Attempt to load rails so that we can determine the proper sub-installer to use.
begin
  require "rails"
rescue LoadError
end

require "timber/cli/api"
require "timber/cli/installer"
require "timber/cli/installers/other"
require "timber/cli/installers/rails"
require "timber/cli/io/messages"
require "timber/cli/os_helper"
require "timber/log_devices/http"
require "timber/logger"

module Timber
  class CLI
    module Installers
      # The root installer is the primary installer that is instantiated and
      # run when the installer starts. It is responsible for instantiating
      # the proper sub installers that install Timber in specific frameworks
      # and environments.
      class Root < Installer
        def run(app)
          io.puts IO::Messages.application_details(app)
          io.puts ""

          case io.ask_yes_no("Are the above details correct?", event_prompt: "App details correct?")
          when :yes
            install_platform(app)
            run_sub_installer(app)
            send_test_messages
            confirm_log_delivery
            wrap_up(app)
            api.event(:success)
            collect_feedback
            free_data

          when :no
            io.puts ""
            io.puts "Bummer. Head to this URL to update the details:"
            io.puts ""
            io.puts "    #{IO::Messages.edit_app_url(app)}", :blue
            io.puts ""
            io.puts "exiting..."
          end
        end

        private
          def install_platform(app)
            if app.heroku?
              io.puts ""
              io.puts IO::Messages.separator
              io.puts ""
              io.puts IO::Messages.heroku_install(app)
              io.puts ""
              io.ask_to_proceed
            end

            true
          end

          def run_sub_installer(app)
            sub_installer = get_sub_installer
            sub_installer.run(app)
          end

          def get_sub_installer
            if defined?(::Rails)
              Rails.new(io, api)
            else
              Other.new(io, api)
            end
          end

          def send_test_messages
            task_message = "Sending test logs"
            io.task(task_message) do
              http_device = LogDevices::HTTP.new(api.api_key)
              logger = Logger.new(http_device)
              logger.info("Welcome to Timber!")
              logger.info("This is a test log to ensure the pipes are working")
              logger.info("Be sure to commit and deploy your app to start seeing real logs")
              # Close flushes and waits
              http_device.close
            end
          end

          def confirm_log_delivery
            task_message = "Confirming log delivery"

            io.task(task_message) do
              api.wait_for_logs do |iteration|
                io.write IO::Messages.task_start(task_message), :blue
                io.write IO::Messages.spinner(iteration), :blue
              end
            end
          end

          def wrap_up(app)
            if app.development? || app.test?
              development_note
            else
              assist_with_commit_and_deploy
            end
          end

          def development_note
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""
            io.puts "All done! To start using Timber:"
            io.puts ""
            io.puts IO::ANSI.colorize("1. Run your application locally to see logs show up in Timber", :blue)
            io.puts IO::ANSI.colorize("2. When you're ready to move to production/staging, create a", :blue)
            io.puts IO::ANSI.colorize("   production/staging app in Timber and follow the instructions shown.", :blue)
            io.puts ""
            io.ask_to_proceed
          end

          def assist_with_commit_and_deploy
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""

            if OSHelper.has_git?
              case io.ask_yes_no("All done! Would you like to commit these changes?", event_prompt: "Run git commands?")
              when :yes
                io.puts ""

                task_message = "Committing changes via git"
                io.task_start(task_message)

                committed = OSHelper.git_commit_changes

                if committed
                  io.task_complete(task_message)
                else
                  io.task_failed(task_message)

                  io.puts ""
                  io.puts "Bummer, it looks like we couldn't access the git command.", :yellow
                  io.puts "No problem though, just run these commands yourself:", :yellow
                  io.puts ""
                  io.puts IO::Messages.git_commands
                end
              when :no
                io.puts ""
                io.puts "No problem. Here's the commands for reference when you're ready:"
                io.puts ""
                io.puts IO::Messages.git_commands
              end
            else
              io.puts ""
              io.puts "All done! Commit your changes:"
              io.puts ""
              io.puts IO::Messages.git_commands
            end

            io.puts ""
            io.puts "=> Reminder: remember to deploy 🚀 to see logs in staging/production", :yellow
          end

          def collect_feedback
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""

            rating = io.ask("How would rate this install experience? 1 (bad) - 5 (perfect)", ["1", "2", "3", "4", "5"])

            case rating
            when "4", "5"
              api.event(:feedback, rating: rating.to_i)
              io.puts ""
              io.puts IO::Messages.we_love_you_too

            when "1", "2", "3"
              io.puts ""
              io.puts IO::Messages.bad_experience_message
              io.puts ""
              io.puts "Type your comments below (enter sends)"
              io.puts ""

              comments = io.gets

              api.event(:feedback, rating: rating.to_i, comments: comments)

              io.puts ""
              io.puts "Thank you! We take feedback seriously and will work to improve this."
            end
          end

          def free_data
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""
            io.puts IO::Messages.free_data
            io.puts ""
          end
      end
    end
  end
end