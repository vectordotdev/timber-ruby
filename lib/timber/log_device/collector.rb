module Timber
  module LogDevice
    module Collector
      def write(*args)
        super.tap do
          LogTruck.drop(args.first)
        end
      end
    end
  end
end
