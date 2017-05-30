require "timber/cli/installer"

module Timber
  class CLI
    module Installers
      class Generic < Installer
        def run(app, api)
          puts ""
          puts Messages.separator
          puts ""
        end
      end
    end
  end
end