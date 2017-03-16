require "erb"
require "ostruct"
require "io/console"

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
            puts "No api key"
            return
          end

          app = Application.new(api_key)

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
              puts Messages.heroku_install(app)

              app.wait_for_logs do |iteration|
                write Messages.task_start("Waiting for logs")
                write Messages.spinner(iteration)
              end

              puts Messages.task_complete()

            else
              puts Messages.separator
              puts ""
              puts "How would you like configure Timber?"
              puts ""
              puts "1) Using environment variables"
              puts "2) Configuring in my app"
              puts ""

              case ask("Enter your choice: (1/2) ")
              when "1"
                puts Messages.environment_variables("http", app.api_key)
              when "2"
                puts "Great!"
                write Message.task_start("Creating config/initializers/timber.rb")

                create_initializer("http", app)

                puts colorize(Messages.task_complete, :green)
              end
            end

            puts ""
            puts Messages.separator
            puts Messages.finish

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
              "# More config options can be found at: https://timber.io/docs/ruby/configuration/\n"
              "# Question? Need help? Contact us: support@timber.io"

            FileUtils.mkdir_p(File.join(Dir.pwd, "config", "initializers"))
            File.write(File.join(Dir.pwd, "config/initializers/timber.rb"), config)
          end
      end
    end
  end
end