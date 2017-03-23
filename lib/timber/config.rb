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

    PRODUCTION_NAME = "production".freeze
    STAGING_NAME = "staging".freeze

    include Singleton

    attr_writer :append_metadata, :debug_logger, :http_body_limit, :logger

    # @private
    def initialize
      @http_body_limit = 2000
    end

    # The environment your app is running in. Defaults to RACK_ENV and RAILS_ENV.
    def environment
      @environment ||= ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"
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

    # Should the logger append the Timber metadata. This is automatically turned on
    # for production and staging environments. Other environments should be set manually.
    # If set to `true` log messages will look like:
    #
    #     log message @metadata {...}
    #
    def append_metadata?
      if defined?(@append_metadata)
        return @append_metadata == true
      end

      production? || staging?
    end

    # This is the logger Timber writes to. It should be set to your global
    # logger to keep the logging destination consitent. Please see `delegate_logger_to`
    # to  delegate this call to another method. This is set to `Rails.logger`
    # for rails.
    def logger
      @logger || Logger.new(STDOUT)
    end

    private
      def production?
        environment == PRODUCTION_NAME
      end

      def staging?
        environment == STAGING_NAME
      end
  end
end