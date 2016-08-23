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
      NEWLINE = "\n".freeze

      attr_reader :formatter

      # Instantiates a new Timber IO log device.
      #
      # @param io [IO] any object the responds to #write(message)
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