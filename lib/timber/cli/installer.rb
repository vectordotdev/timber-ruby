module Timber
  class CLI
    # Simple abstract class for all installers.
    class Installer
      def run(app, api)
        raise NotImplementedError.new
      end
    end
  end
end