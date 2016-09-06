require File.join(File.dirname(__FILE__), "io", "formatter")
require File.join(File.dirname(__FILE__), "io", "hybrid_formatter")
require File.join(File.dirname(__FILE__), "io", "hybrid_hidden_formatter")
require File.join(File.dirname(__FILE__), "io", "json_formatter")
require File.join(File.dirname(__FILE__), "io", "logfmt_formatter")

module Timber
  module LogDevices
    # The purpose of a Timber log device is to take the raw log message and enrich it
    # with the current context.
    #
    # The IO log device works with any IO object. That is, any object that
    # response to #write(message).
    class IO < LogDevice
      attr_reader :formatter

      # Instantiates a new Timber IO log device.
      #
      # @param io [IO] any object the responds to #write(message)
      def initialize(io = STDOUT, options = {})
        io.sync = true if io.respond_to?(:sync=) # ensures logs are written immediately instead of being buffered by ruby
        @formatter = options[:formatter] || HybridHiddenFormatter.new
        @io = io
      end

      def close(*_args)
        io.close
      end

      private
        def write_log_line(log_line)
          formatted_message = formatter.format(log_line)
          io.write(formatted_message + "\n")
        end

        def io
          @io
        end
    end
  end
end