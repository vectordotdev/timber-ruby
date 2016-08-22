module Timber
  module LogDevices
    class IO < LogDevice
      class Line
        CONTEXT_DELIMITER = "[timber.io]".freeze

        attr_reader :io, :message, :colorize

        def initialize(io, message, colorize)
          @io = io
          @message = message
          @colorize = colorize
        end

        def write
          io.write(final_message)
        end

        private
          def colorize?
            colorize == true
          end

          def base_message
            @base_message ||= "#{log_line.formatted_dt}: #{log_line.message}"
          end

          def context_message
            @context_message ||= begin
              text = "#{CONTEXT_DELIMITER} #{encoded_context}"
              colorize? ? LogDevice::Formatter.format(:black, text) : text
            end
          end

          def final_message
            @final_message ||= "#{context_message}\r\r\r\r\r\r\r\r#{base_message}\n"
          end

          def log_line
            @log_line ||= LogLine.new(message)
          end

          def encoded_context
            @encoded_context ||= log_line.context_snapshot.to_logfmt
          end
      end

      NEWLINE = "\n".freeze

      attr_accessor :colorize

      def initialize(io = STDOUT, options = {})
        io.sync = true if io.respond_to?(:sync=) # ensures logs are written immediately instead of being buffered by ruby
        self.colorize = options[:colorize] != false
        @io = io
      end

      def close(*args)
        io.close
      end

      def write(message)
        message.chomp.split(NEWLINE).each do |message|
          line_class.new(io, message, colorize).write
        end
      rescue Exception => e
        Config.logger.exception(e)
        raise e
      end

      private
        def io
          @io
        end

        def line_class
          Line
        end
    end
  end
end