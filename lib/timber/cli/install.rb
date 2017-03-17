require "fileutils"

module Timber
  class CLI
    class Install
      EXCLUDED_ENVIRONMENTS = ["test"].freeze

      class << self
        include IOHelper

        def run(api_key)
          puts ""
          puts colorize(Messages.header, :green)
          puts colorize(Messages.separator, :green)
          puts colorize(Messages.contact, :green)
          puts colorize(Messages.separator, :green)
          puts ""

          if !api_key
            puts colorize(Messages.no_api_key_provided, :red)
            return
          end

          api = API.new(api_key)

          api.event!(:started)

          app = Application.new(api)

          puts "Woot! Your API 🔑  is valid. Here are you application details:"
          puts ""
          puts "Name:      #{app.name} (#{app.environment})"
          puts "Framework: #{app.framework_type}"
          puts "Platform:  #{app.platform_type}"
          puts ""

          case ask_yes_no("Are the above details correct?")
          when :yes
            if app.heroku?
              puts ""
              puts Messages.separator
              puts ""
              puts Messages.heroku_install(app)
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
                puts ""
                puts Messages.http_environment_variables(app.api_key)
                puts ""

              when "2"
                puts ""
                write Messages.task_start("Creating config/initializers/timber.rb")

                create_initializer("http", app)

                puts colorize(Messages.task_complete("Creating config/initializers/timber.rb"), :green)
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
            puts Messages.finish

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
          def create_initializer(log_device, app)
            body = "config.timber.log_device = Timber::LogDevices::HTTP.new(\"#{app.api_key}\")\n\n" \
              "# More config options can be found at: https://timber.io/docs/ruby/configuration/\n" \
              "#\n" \
              "# Question? Need help?\n" \
              "# * Docs: https://timber.io/docs\n" \
              "# * Support: support@timber.io" \

            FileUtils.mkdir_p(File.join(Dir.pwd, "config", "initializers"))
            File.write(File.join(Dir.pwd, "config/initializers/timber.rb"), body)
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