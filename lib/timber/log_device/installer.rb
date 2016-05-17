module Timber
  module LogDevice
    module Installer
      def initialize(*args)
        super.tap do
          # Hack to see current instance included modules
          included_modules = (class << b; self; end).included_modules
          if !included_modules.include?(Collector)
            dev.extend(Collector)
          end
        end
      end
    end
  end
end
