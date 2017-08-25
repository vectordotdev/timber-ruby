begin
  require "lograge"
rescue Exception
end

require "timber/cli/config_file"
require "timber/cli/installer"
require "timber/cli/io/messages"

module Timber
  class CLI
    module Installers
      class ConfigFile < Installer
        def run(app, path)
          config_file = Timber::CLI::ConfigFile.new(path, file_helper)

          if config_file.exists?
            io.task_complete("#{config_file.path} already created")
            return true
          end

          if lograge?
            task_message = "Enabling logrageify in #{config_file.path}"
            io.task(task_message) { config_file.logrageify! }
          elsif action_view?
            task_message = "Silencing template renders in #{config_file.path}"
            io.task(task_message) { config_file.silence_template_renders! }
          end

          task_message = "Creating #{config_file.path}"
          io.task(task_message) { config_file.create! }
        end

        private
          def lograge?
            require "lograge"
            true
          rescue Exception
            false
          end

          def action_view?
            require("action_view")
            true
          rescue Exception
            false
          end
      end
    end
  end
end