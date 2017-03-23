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
              update_environment_config("production", :stdout)

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
                update_environment_config("production", :http, :api_key_code => "ENV['TIMBER_API_KEY']")

                puts ""
                puts Messages.http_environment_variables(app.api_key)
                puts ""

                ask_yes_no("Ready to proceed?")
                puts ""

              when "2"
                update_environment_config("production", :http, :api_key_code => "'#{app.api_key}'")

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
          def update_environment_config(name, log_device_type, options = {})
            path = File.join("config", "environments", "#{name}.rb")

            puts ""
            task_message = "Configuring Timber in #{path}"
            write Messages.task_start(task_message)

            logger_code = \
              case log_device_type
              when :http
                api_key_code = options[:api_key_code] || raise(ArgumentError.new("the :api_key_code option is required"))

                logger_code = defined?(::ActiveSupport::TaggedLogging) ? "ActiveSupport::TaggedLogging.new(logger)" : "logger"

                code = <<-CODE
  # Install the Timber.io logger, send logs over HTTP
  log_device = Timber::LogDevices::HTTP.new(#{api_key_code})
  logger = Timber::Logger.new(log_device)
  logger.level = config.log_level
  config.logger = #{logger_code}
CODE
                code.rstrip

              when :stdout
                code = <<-CODE
  # Install the Timber.io logger, send logs to STDOUT
  logger = Timber::Logger.new(STDOUT)
  logger.level = config.log_level
  config.logger = #{logger_code}
CODE
                code.rstrip
              end


            current_contents = File.read(path)

            if !current_contents.include?("Timber::Logger.new")
              new_contents = current_contents.sub(/\nend/, "\n\n#{logger_code}\nend")
              File.write(path, new_contents)
            end

            puts colorize(Messages.task_complete(task_message), :green)
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
          end
      end
    end
  end
end