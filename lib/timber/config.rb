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

    attr_writer :api_key, :log_device, :log_formatter, :logger

    # Your Timber API key. Defaults to the `TIMBER_API_KEY` environment variable.
    def api_key
      @api_key ||= ENV["TIMBER_API_KEY"]
    end

    # Set a debug_logger to view internal Timber library log message.
    # Useful for debugging. Defaults to `nil`. If set, debug messages will be
    # written to this logger.
    def debug_logger
      @debug_logger
    end

    # This method allows the delegation of the logger method to a given block. This has
    # 2 purposes:
    #
    # 1. It allows us to delegate the logger call to methods like `::Rails.logger`. In
    #    a rails environment, this is generally the main logger and Timber respects it.
    # 2. It allows Timber to call `Config.instance.logger` internally without having to
    #    worry about the environment. This way each framework can be responsible for setup.
    #
    # @private
    def delegate_logger_to(&block)
      @delegate_logger_to = block
    end

    def environment
      ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
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

    # Allows you to change the formatter used when logging messages. This is mostly
    # used for test and development environments, where you want a plain text formatter
    # without the metadata.
    def log_formatter
      return @log_formatter if defined?(@log_formatter)

      @log_formatter = if ["development", "test"].include?(environment)
        Logger::SimpleFormatter.new
      else
        nil
      end
    end

    def logger
      if @delegate_logger_to
        @delegate_logger_to.call
      else
        @logger ||= begin
          logger = Logger.new(log_device)
          logger.formatter = log_formatter

          if defined?(::ActiveSupport::TaggedLogging)
            ::ActiveSupport::TaggedLogging.new(logger)
          else
            logger
          end
        end
      end
    end
  end
end