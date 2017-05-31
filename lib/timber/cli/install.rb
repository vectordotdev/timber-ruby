require "logger"

require "timber/cli/api"
require "timber/cli/installers"
require "timber/cli/io_helper"
require "timber/cli/messages"
require "timber/log_devices/http"
require "timber/logger"

module Timber
  class CLI
    class Install
      EXCLUDED_ENVIRONMENTS = ["test"].freeze

      class << self
        include IOHelper

        def run(api_key)
          puts colorize(Messages.header, :green)
          puts colorize(Messages.separator, :green)
          puts colorize(Messages.contact, :green)
          puts colorize(Messages.separator, :green)
          puts ""

          if !api_key
            puts Messages.no_api_key_provided
            return
          end

          api = API.new(api_key)
          api.event!(:started)

          app = api.application!

          puts Messages.application_details(app)
          puts ""

          case ask_yes_no("Are the above details correct?", api)
          when :yes

            installer = Installers.find
            installer.run(app, api)

            send_test_messages(app.api_key)

            task_message = "Confirming log delivery"

            api.wait_for_logs do |iteration|
              write Messages.task_start(task_message)
              write Messages.spinner(iteration)
            end

            puts colorize(Messages.task_complete(task_message), :green)

            puts ""
            puts Messages.separator
            puts ""
            puts Messages.commit_and_deploy_reminder

            api.event!(:success)

            collect_feedback(api)

            puts ""
            puts Messages.separator
            puts ""
            puts Messages.free_data
            puts ""

          when :no
            puts ""
            puts "Bummer. Head to this URL to update the details:"
            puts ""
            puts "    #{Messages.edit_app_url(app)}"
            puts ""
            puts "exiting..."
            return false
          end
        end

        private
          def send_test_messages(api_key)
            task_message = "Sending test logs"
            write Messages.task_start(task_message)

            http_device = LogDevices::HTTP.new(api_key, flush_continuously: false)
            logger = Logger.new(http_device)
            logger.info("Welcome to Timber!")
            logger.info("This is a test log to ensure the pipes are working")
            logger.info("Be sure to commit and deploy your app to start seeing real logs")
            http_device.flush

            puts colorize(Messages.task_complete(task_message), :green)
          end

          def collect_feedback(api)
            puts ""
            puts Messages.separator
            puts ""

            rating = ask("How would rate this install experience? 1 (bad) - 5 (perfect)", ["1", "2", "3", "4", "5"], api)

            case rating
            when "4", "5"
              api.event!(:feedback, rating: rating.to_i)
              puts ""
              puts Messages.we_love_you_too

            when "1", "2", "3"
              puts ""
              puts Messages.bad_experience_message
              puts ""
              puts "Type your comments below (enter sends)"
              puts ""

              comments = gets

              api.event!(:feedback, rating: rating.to_i, comments: comments)

              puts ""
              puts "Thank you! We take feedback seriously and will work to improve this."
            end
          end
      end
    end
  end
end