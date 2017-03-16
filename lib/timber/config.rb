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
    include Singleton

    attr_writer :api_key, :log_device, :logger

    def api_key
      @api_key ||= ENV["TIMBER_LOG_DEVICE"]
    end

    # The target device that logs are written to. Must respond to #write and #close.
    #
    # Configure this with an environment variable. `TIMBER_LOG_DEVICE`, must be
    # one of `stdout` or `http`. If using `http`, you must supply an API key. See
    # {api_key}.
    def log_device
      @log_device ||= case (ENV["TIMBER_LOG_DEVICE"] || "stdout").downcase
        when "stdout"
          STDOUT
        when "http"
          Timber::LogDevices::HTTP.new(api_key)
        end
    end

    # Set a debug_logger to view internal Timber library log message.
    # Useful for debugging. Defaults to `nil`. If set, debug messages will be
    # written to this logger.
    def debug_logger
      @debug_logger
    end
  end
end