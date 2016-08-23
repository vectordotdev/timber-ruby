module Timber
  module LogDevices
    class IO < LogDevice
      class LogfmtFormatter < Formatter
        def format(log_line)
          log_line.to_logfmt
        end
      end
    end
  end
end