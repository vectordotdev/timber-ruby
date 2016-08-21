module Timber
  module LogDevices
    class HerokuLogplex < IO
      class Line < IO::Line
        private
          def base_message
            # remove dt since that is included by default in the logplex format
            @base_message ||= log_line.message
          end

          def context_hash
            # remove heroku since that is included by default in the logplex format
            @context_hash ||= log_line.context_snapshot.context_hash(:except => [Contexts::Servers::HerokuSpecific])
          end
      end

      def initialize
        super(STDOUT)
      end

      def write(message)
        Line.new(io, message).write
      rescue Exception => e
        Config.logger.exception(e)
        raise e
      end
    end
  end
end