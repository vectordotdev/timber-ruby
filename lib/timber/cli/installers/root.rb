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

          run_sub_installer(app)
          send_test_messages
          confirm_log_delivery
          api.event(:success)
          collect_feedback
          wrap_up(app)
        end

        private
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
              logger.debug("Welcome to Timber!")
              logger.debug("This is a test log to ensure the pipes are working")
              logger.debug("Be sure to commit and deploy your app to start seeing real logs")
              # Close flushes and waits
              http_device.close
            end
          end

          def confirm_log_delivery
            task_message = "Confirming log delivery"

            io.task(task_message) do
              api.wait_for_logs do |iteration|
                io.write(IO::Messages.task_start(task_message), :blue)
                io.write(IO::Messages.spinner(iteration), :blue)
              end
            end
          end

          def wrap_up(app)
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""
            io.puts IO::ANSI.colorize("All done! Commit and deploy 🚀  to see logs in Timber.", :yellow)
            io.puts IO::ANSI.colorize("You can also test drive Timber by starting your app locally.", :yellow)
            io.puts ""
          end

          def collect_feedback
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""

            rating = io.ask("How would rate this install experience? 1 (bad) - 5 (perfect) or 'skip':", ["1", "2", "3", "4", "5", "skip"])

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
      end
    end
  end
end