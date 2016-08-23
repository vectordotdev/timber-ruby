require File.join(File.dirname(__FILE__), "io", "formatter")
require File.join(File.dirname(__FILE__), "io", "hybrid_formatter")
require File.join(File.dirname(__FILE__), "io", "hybrid_hidden_formatter")
require File.join(File.dirname(__FILE__), "io", "json_formatter")
require File.join(File.dirname(__FILE__), "io", "logfmt_formatter")

module Timber
  module LogDevices
    class IO < LogDevice
      NEWLINE = "\n".freeze

      attr_reader :formatter

      def initialize(io = STDOUT, options = {})
        io.sync = true if io.respond_to?(:sync=) # ensures logs are written immediately instead of being buffered by ruby
        @formatter = options[:formatter] || HybridHiddenFormatter.new
        @io = io
      end

      def close(*args)
        io.close
      end

      def write(message)
        message.chomp.split(NEWLINE).each do |message|
          log_line = LogLine.new(message)
          message = formatter.format(log_line)
          io.write(message + "\n")
        end
        true
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