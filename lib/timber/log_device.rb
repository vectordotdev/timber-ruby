module Timber
  class LogDevice
    NEWLINE = "\n".freeze
    SPLIT_LINES = true

    def write(message)
      return false if ignoring?
      ignore do
        messages(message).each do |message_part|
          log_line = LogLine.new(message_part)
          write_log_line(log_line)
        end
      end
      true
    rescue Exception => e
      Config.logger.exception(e)
      raise e
    end

    private
      def ignore(&block)
        @ignoring = true
        yield
      ensure
        @ignoring = false
      end

      def ignoring?
        @ignoring == true
      end

      def messages(message)
        message.chomp.split(NEWLINE)
      end

      def write_formatted(formatted_message)
        raise NotImplementedError.new
      end
    end
end