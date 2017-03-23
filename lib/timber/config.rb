require "singleton"

module Timber
  # Interface for setting and reading Timber configuration.
  #
  # For Rails apps this is installed into `config.timber`. See examples below.
  #
  # @example Rails example
  #   config.timber.append_metadata = false
  # @example Everything else
  #   config = Timber::Config.instance
  #   config.append_metdata = false
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

    # The environment your app is running in. Defaults to `RACK_ENV` and `RAILS_ENV`.
    #
    # @example Rails
    #   config.timber.environment = "staging"
    # @example Everything else
    #   Timber::Config.instance.environment = "staging"
    def environment
      @environment ||= ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"
    end

    # Set a debug_logger to view internal Timber library log message.
    # Useful for debugging. Defaults to `nil`. If set, debug messages will be
    # written to this logger.
    #
    # @example Rails
    #   config.timber.debug_logger = ::Logger.new(STDOUT)
    # @example Everything else
    #   Timber::Config.instance.debug_logger = ::Logger.new(STDOUT)
    def debug_logger
      @debug_logger
    end

    # Truncates captured HTTP bodies to this specified limit. The default is `2000`.
    # If you want to capture more data, you can raise this to a maximum of `5000`,
    # or lower this to be more efficient with data.
    #
    # @example Rails
    #   config.timber.http_body_limit = 500
    # @example Everything else
    #   Timber::Config.instance.http_body_limit = 500
    def http_body_limit
      @http_body_limit
    end

    # Should the logger append the Timber metadata. This is automatically turned on
    # for production and staging environments. Other environments should be set manually.
    # If set to `true` log messages will look like:
    #
    #     log message @metadata {...}
    #
    # @example Rails
    #   config.timber.append_metadata = false
    # @example Everything else
    #   Timber::Config.instance.append_metadata = false
    def append_metadata?
      if defined?(@append_metadata)
        return @append_metadata == true
      end

      production? || staging?
    end

    # This is the logger Timber writes to. All of the Timber integrations write to
    # this logger. It should be set to your global logger to keep the logging destination consitent.
    #
    # For Rails this is set automatically to `Rails.logger`.
    #
    # @example Rails
    #   Rails.logger = Timber::Logger.new(STDOUT)
    #   config.timber.logger = Rails.logger
    # @example Everything else
    #   Timber::Config.instance.logger = Timber::Logger.new(STDOUT)
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