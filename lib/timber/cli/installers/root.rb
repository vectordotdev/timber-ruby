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

            assist_with_git

            api.event!(:success)

            collect_feedback

            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""
            io.puts IO::Messages.free_data
            io.puts ""

            true

          when :no
            io.puts ""
            io.puts "Bummer. Head to this URL to update the details:"
            io.puts ""
            io.puts "    #{IO::Messages.edit_app_url(app)}", :blue
            io.puts ""
            io.puts "exiting..."

            false
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

          def assist_with_git
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""
            io.puts "Last step! We need to commit these changes via git:"
            io.puts ""
            io.puts IO::Messages.git_commands
            io.puts ""

            if OSHelper.has_git?
              case io.ask_yes_no("We can run these commands for you. Shall we?", event_prompt: "Run git commands?")
              when :yes
                io.puts ""

                task_message = "Committing changes via git"
                io.write IO::Messages.task_start(task_message)

                committed = OSHelper.git_commit_changes

                if committed
                  io.puts IO::Messages.task_complete(task_message), :green
                else
                  io.puts IO::Messages.task_failed(task_message), :red

                  io.puts ""
                  io.puts "Bummer, it looks like we couldn't access the git command.", :yellow
                  io.puts "No problem though, just copy and paste the above commands to", :yellow
                  io.puts "run them manually.", :yellow
                end
              when :no
                io.puts ""
                io.puts "No problem. Just copy and paste the above commands to run them manually."
              end
            else
              io.puts ""
              io.puts "Finally, commit your changes:"
              io.puts ""
              io.puts IO::Messages.git_commands
            end

            io.puts ""
            io.puts "=> Reminder: git push and deploy 🚀 to see logs in staging/production", :yellow
          end

          def collect_feedback
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""

            rating = io.ask("How would rate this install experience? 1 (bad) - 5 (perfect)", ["1", "2", "3", "4", "5"])

            case rating
            when "4", "5"
              api.event!(:feedback, rating: rating.to_i)
              io.puts ""
              io.puts IO::Messages.we_love_you_too

            when "1", "2", "3"
              io.puts ""
              io.puts IO::Messages.bad_experience_message
              io.puts ""
              io.puts "Type your comments below (enter sends)"
              io.puts ""

              comments = io.gets

              api.event!(:feedback, rating: rating.to_i, comments: comments)

              io.puts ""
              io.puts "Thank you! We take feedback seriously and will work to improve this."
            end
        end
      end
    end
  end
end