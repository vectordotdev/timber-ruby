require "fileutils"

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

          app = Application.new(api)

          puts Messages.application_details(app)
          puts ""

          case ask_yes_no("Are the above details correct?")
          when :yes
            if app.heroku?
              create_initializer(:stdout)

              puts ""
              puts Messages.separator
              puts ""
              puts Messages.heroku_install(app)
              puts ""

              ask_yes_no("Ready to proceed?")
              puts ""

            else
              puts ""
              puts Messages.separator
              puts ""
              puts "How would you like configure Timber?"
              puts ""
              puts "1) Using environment variables"
              puts "2) Configuring in my app"
              puts ""

              case ask("Enter your choice: (1/2) ")
              when "1"
                create_initializer(:http, :api_key_code => "ENV['TIMBER_API_KEY']")

                puts ""
                puts Messages.http_environment_variables(app.api_key)
                puts ""

                ask_yes_no("Ready to proceed?")
                puts ""

              when "2"
                create_initializer(:http, :api_key_code => "'#{app.api_key}'")

              end

              send_test_messages(api_key)
            end


            api.wait_for_logs do |iteration|
              write Messages.task_start("Waiting for logs")
              write Messages.spinner(iteration)
            end

            puts colorize(Messages.task_complete("Waiting for logs"), :green)

            puts ""
            puts Messages.separator
            puts ""
            puts Messages.free_data
            puts ""
            puts Messages.separator
            puts ""
            puts Messages.commit_and_deploy_reminder

            api.event!(:success)

            collect_feedback(api)

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
          def create_initializer(log_device_type, options = {})
            puts ""
            write Messages.task_start("Creating config/initializers/timber.rb")

            logger_code = \
              case log_device_type
              when :http
                api_key_code = options[:api_key_code] || raise(ArgumentError.new("the :api_key_code option is required"))
                "log_device = Timber::LogDevices::HTTP.new(#{api_key_code})\n" +
                  "Timber::Logger.new(log_device)"

              when :stdout
                "Timber::Logger.new(STDOUT)"
              end

            body = <<-BODY
# Timber.io Ruby Library
#
#  ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^
# /|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
# /|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
# /|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\
#
# Library:  http://github.com/timberio/timber-ruby
# Docs:     http://www.rubydoc.info/github/timberio/timber-ruby
# Support:  support@timber.io

logger = case Rails.env
when "development", "test"
  logger = Timber::Logger.new(STDOUT)
  logger.formatter = Timber::Logger::SimpleFormatter.new
  logger
else
  #{logger_code}
end

Timber::Frameworks::Rails.set_logger(logger)
BODY

            FileUtils.mkdir_p(File.join(Dir.pwd, "config", "initializers"))
            File.write(File.join(Dir.pwd, "config/initializers/timber.rb"), body)

            puts colorize(Messages.task_complete("Creating config/initializers/timber.rb"), :green)
          end

          def send_test_messages(api_key)
            write Messages.task_start("Sending test logs")

            http_device = LogDevices::HTTP.new(api_key)
            logger = Logger.new(http_device)
            logger.info("test")

            puts colorize(Messages.task_complete("Sending test logs"), :green)
          end

          def collect_feedback(api)
            puts ""
            puts Messages.separator
            puts ""
            rating = ask("How would rate this install experience? 1 (bad) - 5 (perfect)")
            case rating
            when "4", "5"
              api.event!(:feedback, rating: rating.to_i)
              puts ""
              puts Messages.we_love_you_too

            when "1", "2", "3"
              puts ""
              puts Messages.bad_experience_message
              puts ""

              comments = ask("Type your comments (enter sends)")

              api.event!(:feedback, rating: rating.to_i, comments: comments)

              puts ""
              puts "Thank you! We take feedback seriously and will work to improve this."
            end

            puts ""
          end
      end
    end
  end
end