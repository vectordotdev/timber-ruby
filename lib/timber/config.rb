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

    FORM_URL_ENCODED_CONTENT_TYPE = "application/x-www-form-urlencoded".freeze
    JSON_CONTENT_TYPE = "application/json".freeze

    include Singleton

    attr_writer :capture_http_bodies, :debug_logger, :log_formatter, :logger

    def initialize
      @capture_http_bodies = true
      @capture_http_body_content_types = [FORM_URL_ENCODED_CONTENT_TYPE, JSON_CONTENT_TYPE]
    end

    # Enables and disables the capturing of HTTP bodies in `Events::HTTPServerRequest`,
    # `HTTPClientRequest`, and `HTTPClientRespone`.
    def capture_http_bodies?
      @capture_http_bodies == true
    end

    # Limits HTTP body capturing to the listed content types. This must be an array.
    def capture_http_body_content_types
      @capture_http_body_content_types ||= []
    end

    # Set a debug_logger to view internal Timber library log message.
    # Useful for debugging. Defaults to `nil`. If set, debug messages will be
    # written to this logger.
    def debug_logger
      @debug_logger
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