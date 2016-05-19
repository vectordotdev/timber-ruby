module Timber
  module LogDevice
    module Collector
      def write(*args)
        super.tap do
          message = args.first
          log_line = LogLine.new(message)
          LogYard.drop(log_line)
        end
      end
    end
  end
end
