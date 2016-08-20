module Timber
  module LogDevices
    class IO < LogDevice
      def initialize(io = STDOUT)
        @io = io
      end

      def close(*args)
        io.close
      end

      def write(message)
        log_line = LogLine.new(message)
        io.write(log_line.to_logfmt + "\n")
      rescue Exception => e
        Config.logger.exception(e)
        raise e
      end

      private
        def io
          @io
        end
    end
  end
end