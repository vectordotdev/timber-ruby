module Timber
  module LogDevices
    class HerokuLogplex < IO
      def initialize
        STDOUT.sync = true # ensures logs are written immediately instead of being buffered by ruby
        super(STDOUT)
      end

      def write(message)
        # Cleanup dt, server.heroku context, and move at and message to the front
        log_line = LogLine.new(message.chomp)
        logfmt = log_line.to_logfmt(:except => [:dt]) + "\n"
        io.write(logfmt)
      rescue Exception => e
        Config.logger.exception(e)
        raise e
      end
    end
  end
end