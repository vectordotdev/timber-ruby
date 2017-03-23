require "singleton"

module Timber
  # Interface for settings and reading Timber configuration.
  #
  # You can override any configuration supplied here by simply setting it:
  #
  #     # Rails
  #     config.timber.api_key = "my api key"
  #
  #     # Everything else
  #     Timber::Config.instance.api_key = "my api key"
  #
  # If a value is not explicity set, the environment is checked for it's associated
  # environment variable. If that is not set, a reasonable default will be chosen. Each
  # method documents this.
  class Config
    class NoLoggerError < StandardError; end

    include Singleton

    attr_writer :debug_logger, :http_body_limit, :logger

    def initialize
      @http_body_limit = 2000
    end


    # Set a debug_logger to view internal Timber library log message.
    # Useful for debugging. Defaults to `nil`. If set, debug messages will be
    # written to this logger.
    def debug_logger
      @debug_logger
    end

    # Truncates captured HTTP bodies to this specified limit. The default is `2000`.
    # If you want to capture more data, you can raise this to a maximum of `5000`,
    # or lower this to be more efficient with data.
    def http_body_limit
      @http_body_limit
    end

    # This is the logger Timber writes to. It should be set to your global
    # logger to keep the logging destination consitent. Please see `delegate_logger_to`
    # to  delegate this call to another method. This is set to `Rails.logger`
    # for rails.
    def logger
      @logger || raise(NoLoggerError.new)
    end
  end
end