require "timber/cli/installer"
require "timber/cli/installers/config_file"
require "timber/cli/io/messages"

module Timber
  class CLI
    module Installers
      class Rails < Installer
        # Runs the installer.
        def run(app)
          install_initializer(app)
          install_development_environment(app)
          install_test_environment(app)

          if !app.development? && !app.test?
            install_app_environment(app)
          end
        end

        private
          def install_initializer(app)
            initializer_path = File.join("config", "initializers", "timber.rb")
            installer = ConfigFile.new(io, api)
            installer.run(app, initializer_path)
          end

          # Determines the development preference
          def get_development_preference(app)
            if app.development?
              return :send
            else
              io.puts ""
              io.puts IO::Messages.separator
              io.puts ""
              io.puts "Would you like to temporarily send development logs to this Timber app?"
              io.puts "(Logs will still go to STDOUT, but this provides an easy way to kick the "
              io.puts "tires. Once you're done testing, you can disable this in "
              io.puts "#{IO::ANSI.colorize("config/environments/development.rb", :yellow)})"
              io.puts ""
              io.puts "y) Yes, send development logs to Timber", :blue
              io.puts "n) No, just print development logs to STDOUT", :blue
              io.puts ""

              input = io.ask_yes_no("Enter your choice:", event_prompt: "Send dev logs to Timber?")

              io.puts ""
              io.puts IO::Messages.separator
              io.puts ""

              case input
              when :yes
                :send
              when :no
                :dont_send
              end
            end
          end

          def install_development_environment(app)
            environment_file_path = get_environment_file_path("development")
            if environment_file_path
              if already_installed?(environment_file_path)
                io.task_complete("Timber already installed #{environment_file_path}")
                return :already_installed
              end

              development_preference = get_development_preference(app)

              case development_preference
              when :send
                api_key_code = get_api_key_code(:inline)

                logger_code = <<-CODE
  # Install the Timber.io logger
  # ----------------------------
  # Remove the `http_device` to stop sending development logs to Timber.
  # Be sure to keep the `file_device` or replace it with `STDOUT`.
  http_device = Timber::LogDevices::HTTP.new(#{api_key_code})
  file_device = File.open("\#{Rails.root}/log/development.log", "a")
  file_device.binmode
  log_devices = [http_device, file_device]

  # Do not modify below this line. It's important to keep the `Timber::Logger`
  # because it provides an API for logging structured data and capturing context.
  logger = Timber::Logger.new(*log_devices)
  logger.level = config.log_level
  config.logger = #{config_set_logger_code}
CODE

                install_logger(environment_file_path, logger_code)
                return :http

              else
                install_stdout(environment_file_path)
                return :stdout
              end
            end
          end

          def install_test_environment(app)
            environment_file_path = get_environment_file_path("test")
            if environment_file_path
              if already_installed?(environment_file_path)
                io.task_complete("Timber already installed #{environment_file_path}")
                return :already_installed
              end

              # Tests should not be logged by default.
              install_nil(environment_file_path)
              :nil
            end
          end

          def install_app_environment(app)
            environment_file_path = get_environment_file_path(app.environment) || get_environment_file_path("production")
            if environment_file_path
              if already_installed?(environment_file_path)
                io.task_complete("Timber already installed #{environment_file_path}")
                return :already_installed
              end

              case get_delivery_strategy(app)
              when :http
                api_key_storage_preference = get_api_key_storage_preference
                install_http(environment_file_path, api_key_storage_preference)
                :http
              when :stdout
                install_stdout(environment_file_path)
                :stdout
              end
            end
          end

          # Wraps the logger in TaggedLogging if it is available. Older versions of Rails
          # do not include this constant.
          def config_set_logger_code
            @config_set_logger_code ||= defined?(::ActiveSupport::TaggedLogging) ?
              "ActiveSupport::TaggedLogging.new(logger)" : "logger"
          end

          def get_environment_file_path(environment)
            path = File.join("config", "environments", "#{environment}.rb")
            file_helper.exists?(path) ? path : nil
          end

          def install_nil(environment_file_path)
            logger_code = <<-CODE
  # Install the Timber.io logger
  # ----------------------------
  # `nil` is passed to disable logging. It's important to keep the `Timber::Logger`
  # because it provides an API for logging structured data and capturing context.
  logger = Timber::Logger.new(nil)
  logger.level = config.log_level
  config.logger = #{config_set_logger_code}
CODE

            install_logger(environment_file_path, logger_code)
          end

          # Installs the Timber logger using the HTTP transport strategy in the
          # specified environment file.
          def install_http(environment_file_path, api_key_storage_type)
            api_key_code = get_api_key_code(api_key_storage_type)

            logger_code = <<-CODE
  # Install the Timber.io logger, send logs over HTTP.
  log_device = Timber::LogDevices::HTTP.new(#{api_key_code})
  logger = Timber::Logger.new(log_device)
  logger.level = config.log_level
  config.logger = #{config_set_logger_code}
CODE

            install_logger(environment_file_path, logger_code)
          end

          # Installs the Timber logger using the STDOUT transport method in the specified
          # environment file.
          def install_stdout(environment_file_path)
            logger_code = <<-CODE
  # Install the Timber.io logger, send logs over STDOUT. Actual log delivery
  # to the Timber service is handled external of this application.
  logger = Timber::Logger.new(STDOUT)
  logger.level = config.log_level
  config.logger = #{config_set_logger_code}
CODE

            install_logger(environment_file_path, logger_code)
          end

          # Determines if the environment is already installed.
          def already_installed?(environment_file_path)
            environment_file_contents = get_environment_file_contents(environment_file_path)
            logger_installed?(environment_file_contents)
          end

          # Convenience method for getting the current environment file contents.
          def get_environment_file_contents(environment_file_path)
            file_helper.read(environment_file_path)
          end

          # Determines if the Timber logger is already installed in the environment
          # file contents.
          def logger_installed?(environment_file_contents)
            environment_file_contents.include?("Timber::Logger.new")
          end

          # Installs the Timber logger in the specified environment file with the
          # provided logger code.
          def install_logger(environment_file_path, logger_code)
            current_contents = get_environment_file_contents(environment_file_path)

            task_message = "Installing the Timber::Logger in #{environment_file_path}"
            io.task(task_message) do
              if !logger_installed?(current_contents)
                new_contents = current_contents.sub(/\nend/, "\n\n#{logger_code}\nend")
                file_helper.write(environment_file_path, new_contents)
              end
            end

            true
          end
      end
    end
  end
end