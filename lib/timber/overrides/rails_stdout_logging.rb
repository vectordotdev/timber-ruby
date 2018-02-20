# See https://github.com/heroku/rails_stdout_logging
# I have no idea why this library was created, because logging to STDOUT is 1 line of code.
# This library completely obliterates any logger configuration you set by replacing
# your logging with a logger that writes to STDOUT. We disable this because Timber explicitly
# sets your logging in your environment configuration files.

begin
  require "rails_stdout_logging"

  module RailsStdoutLogging
    class Rails2 < Rails
      def self.set_logger
      end
    end

    class Rails3 < Rails
      def self.set_logger(config)
      end
    end
  end
rescue Exception
end