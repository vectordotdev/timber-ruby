module Timber
  module LogDevices
    class IO < LogDevice
      class Line
        CONTEXT_DELIMITER = "[timber.io]".freeze

        attr_reader :io, :message

        def initialize(io, message)
          @io = io
          @message = message
        end

        def write
          io.write(final_message)
        end

        private
          def base_message
            @base_message ||= "#{log_line.formatted_dt}: #{log_line.message}"
          end

          def context_message
            @context_message ||= LogDevice::Formatter.format(:black, "#{CONTEXT_DELIMITER} #{encoded_hash}")
          end

          def final_message
            @final_message ||= "#{base_message} #{context_message}\n"
          end

          def log_line
            @log_line ||= LogLine.new(message.chomp)
          end

          def context_hash
            @context_hash ||= log_line.context_snapshot.context_hash
          end

          def encoded_hash
            @encoded_hash ||= Macros::LogfmtEncoder.encode(context_hash)
          end
      end

      def initialize(io = STDOUT)
        io.sync = true if io.respond_to?(:sync=) # ensures logs are written immediately instead of being buffered by ruby
        @io = io
      end

      def close(*args)
        io.close
      end

      def write(message)
        Line.new(io, message).write
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