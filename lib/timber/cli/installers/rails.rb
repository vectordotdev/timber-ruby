begin
  require "lograge"
rescue Exception
end

require "timber/cli/file_helper"
require "timber/cli/installer"
require "timber/cli/io/messages"

module Timber
  class CLI
    module Installers
      class Rails < Installer
        # Runs the installer.
        def run(app)
          # Ask all of the questions up front. This allows us to to apply the
          # changes as a neat task list when done.
          development_preference = get_development_preference
          api_key_storage_preference = get_api_key_storage_preference
          should_logrageify = logrageify?

          io.puts ""
          io.puts IO::Messages.separator
          io.puts ""

          if should_logrageify
            logrageify!
          end

          environment_file_paths.each do |environment_file_path|
            environment = File.split(environment_file_path).last.gsub(/\.rb$/, "").to_sym

            case environment
            when :development
              setup_development_environment(environment_file_path, development_preference)
            when :test
              setup_test_environment(environment_file_path)
            else
              setup_other_environment(app, environment_file_path, api_key_storage_preference)
            end
          end

          true
        end

        private
          def logrageify?
            if defined?(::Lograge)
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

          def logrageify!
            initializer_path = File.join("config", "initializers", "timber.rb")

            task_message = "Logrageifying in #{initializer_path}"
            io.write IO::Messages.task_start(task_message)

            initializer_content = get_initializer_content(initializer_path)

            if !initializer_content.include?("logrageify!")
              code = "config.logrageify!"
              FileHelper.append(initializer_path, code)
            end

            io.puts IO::Messages.task_complete(task_message), :green
            true
          end

          # Determines the development preference
          def get_development_preference
            io.puts ""
            io.puts IO::Messages.separator
            io.puts ""
            io.puts "Would you like to temporarily send development logs to Timber?"
            io.puts "(Logs will still go to STDOUT, but this provides an easy way to kick the "
            io.puts "tires. Once you're done testing, you can disable this in "
            io.puts "#{IO::ANSI.colorize("config/environments/development.rb", :yellow)})"
            io.puts ""
            io.puts "y) Yes, send development logs to Timber", :blue
            io.puts "n) No, just print development logs to STDOUT", :blue
            io.puts ""

            case io.ask_yes_no("Enter your choice:", event_prompt: "Send dev logs to Timber?")
            when :yes
              :send
            when :no
              :dont_send
            end
          end

          def get_initializer_content(initializer_path)
            config_code = "config = Timber::Config.instance\n"
            FileHelper.read_or_create(initializer_path, config_code)
          end

          # Wraps the logger in TaggedLogging if it is available. Older versions of Rails
          # do not include this constant.
          def config_set_logger_code
            @config_set_logger_code ||= defined?(::ActiveSupport::TaggedLogging) ?
              "ActiveSupport::TaggedLogging.new(logger)" : "logger"
          end

          # Traverses the config/environments directory and returns an array of
          # symbols representing the various environments.
          def environment_file_paths
            path = File.join("config", "environments", "*.rb")
            Dir[path]
          end

          def setup_development_environment(environment_file_path, development_preference)
            if already_configured?(environment_file_path)
              message = "Installing the Timber::Logger in #{environment_file_path}"
              io.puts IO::Messages.task_complete(message), :green
              return true
            end

            case development_preference
            when :send
              extra_comment = <<-NOTE
# Note: When you are done testing, simply instantiate the logger like this:
#
#   logger = Timber::Logger.new(STDOUT)
#
# Be sure to remove the "log_device =" and "logger =" lines below.
NOTE
              extra_comment = extra_comment.rstrip
              install_http(environment_file_path, :inline, extra_comment: extra_comment)
            when :dont_send
              install_stdout(environment_file_path)
            end
          end

          def setup_test_environment(environment_file_path)
            if already_configured?(environment_file_path)
              message = "Installing the Timber::Logger in #{environment_file_path}"
              io.puts IO::Messages.task_complete(message), :green
              return true
            end

            # Tests should not be logged by default.
            install_nil(environment_file_path)
          end

          def setup_other_environment(app, environment_file_path, api_key_storage_preference)
            if already_configured?(environment_file_path)
              message = "Installing the Timber::Logger in #{environment_file_path}"
              io.puts IO::Messages.task_complete(message), :green
              return true
            end

            if app.heroku?
              install_stdout(environment_file_path)
            else
              install_http(environment_file_path, api_key_storage_preference)
            end
          end

          def install_nil(environment_file_path)
            logger_code = <<-CODE
  # Install the Timber.io logger but silence all logs (log to nil). We install the
  # logger to ensure the Rails.logger object exposes the proper API.
  logger = Timber::Logger.new(nil)
  logger.level = config.log_level
  config.logger = #{config_set_logger_code}
CODE

            install_logger(environment_file_path, logger_code)
          end

          # Installs the Timber logger using the HTTP transport strategy in the
          # specified environment file.
          def install_http(environment_file_path, api_key_storage_type, options = {})
            api_key_code = get_api_key_code(api_key_storage_type)
            extra_comment = options[:extra_comment] ? "\n  #{options[:extra_comment]}" : nil

            logger_code = <<-CODE
  # Install the Timber.io logger, send logs over HTTP.#{extra_comment}
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

          # Determines if the environment is already configured.
          def already_configured?(environment_file_path)
            environment_file_contents = get_environment_file_contents(environment_file_path)
            logger_installed?(environment_file_contents)
          end

          # Convenience method for getting the current environment file contents.
          def get_environment_file_contents(environment_file_path)
            FileHelper.read(environment_file_path)
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
            io.write IO::Messages.task_start(task_message)

            if !logger_installed?(current_contents)
              new_contents = current_contents.sub(/\nend/, "\n\n#{logger_code}\nend")
              FileHelper.write(environment_file_path, new_contents)
              api.event(:file_written, path: environment_file_path)
            end

            io.puts IO::Messages.task_complete(task_message), :green

            true
          end
      end
    end
  end
end