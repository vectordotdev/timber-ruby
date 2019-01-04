require "logger"
require "singleton"

module Timber
  # Singleton class for reading and setting Timber configuration.
  #
  # For Rails apps, this is installed into `config.timber`. See examples below.
  #
  # @example Rails example
  #   config.timber.append_metadata = false
  # @example Everything else
  #   config = Timber::Config.instance
  #   config.append_metdata = false
  class Config
    # @private
    class NoLoggerError < StandardError; end

    # @private
    class SimpleLogFormatter < ::Logger::Formatter
      # This method is invoked when a log event occurs
      def call(severity, timestamp, progname, msg)
        "[Timber] #{String === msg ? msg : msg.inspect}\n"
      end
    end

    DEVELOPMENT_NAME = "development".freeze
    PRODUCTION_NAME = "production".freeze
    STAGING_NAME = "staging".freeze
    TEST_NAME = "test".freeze

    include Singleton

    attr_writer :http_body_limit

    # Convenience method for logging debug statements to the debug logger
    # set in this class.
    # @private
    def debug(&block)
      debug_logger = Config.instance.debug_logger
      if debug_logger
        message = yield
        debug_logger.debug(message)
      end
      true
    end

    # This is useful for debugging. This Sets a debug_logger to view internal Timber library
    # log messages. The default is `nil`. Meaning log to nothing.
    #
    # See {#debug_to_file!} and {#debug_to_stdout!} for convenience methods that handle creating
    # and setting the logger.
    #
    # @example Rails
    #   config.timber.debug_logger = ::Logger.new(STDOUT)
    # @example Everything else
    #   Timber::Config.instance.debug_logger = ::Logger.new(STDOUT)
    def debug_logger=(value)
      @debug_logger = value
    end

    # Accessor method for {#debug_logger=}.
    def debug_logger
      @debug_logger
    end

    # A convenience method for writing internal Timber debug messages to a file.
    #
    # @example Rails
    #   config.timber.debug_to_file!("#{Rails.root}/log/timber.log")
    # @example Everything else
    #   Timber::Config.instance.debug_to_file!("log/timber.log")
    def debug_to_file!(file_path)
      FileUtils.mkdir_p( File.dirname(file_path) )
      file = File.open(file_path, "ab")
      file_logger = ::Logger.new(file)
      file_logger.formatter = SimpleLogFormatter.new
      self.debug_logger = file_logger
    end

    # A convenience method for writing internal Timber debug messages to STDOUT.
    #
    # @example Rails
    #   config.timber.debug_to_stdout!
    # @example Everything else
    #   Timber::Config.instance.debug_to_stdout!
    def debug_to_stdout!
      stdout_logger = ::Logger.new(STDOUT)
      stdout_logger.formatter = SimpleLogFormatter.new
      self.debug_logger = stdout_logger
    end

    # The environment your app is running in. Defaults to `RACK_ENV` and `RAILS_ENV`.
    # It should be rare that you have to set this. If the aforementioned env vars are not
    # set please do.
    #
    # @example If you do not set `RACK_ENV` or `RAILS_ENV`
    #   Timber::Config.instance.environment = "staging"
    def environment=(value)
      @environment = value
    end

    # Accessor method for {#environment=}
    def environment
      @environment ||= ENV["RACK_ENV"] || ENV["RAILS_ENV"] || "development"
    end

    # Convenience method for accessing the various `Timber::Integrations::*` class
    # settings. These provides settings for enabling, disabled, and silencing integrations.
    # See {Integrations} for a full list of available methods.
    def integrations
      Integrations
    end

    # This is the _main_ logger Timber writes to. All of the Timber integrations write to
    # this logger instance. It should be set to your global logger. For Rails, this is set
    # automatically to `Rails.logger`, you should not have to set this.
    #
    # @example Non-rails frameworks
    #   my_global_logger = Timber::Logger.new(STDOUT)
    #   Timber::Config.instance.logger = my_global_logger
    def logger=(value)
      @logger = value
    end

    # Accessor method for {#logger=}.
    def logger
      if @logger.is_a?(Proc)
        @logger.call()
      else
        @logger ||= Logger.new(STDOUT)
      end
    end

    # @private
    def development?
      environment == DEVELOPMENT_NAME
    end

    # @private
    def test?
      environment == TEST_NAME
    end

    # @private
    def production?
      environment == PRODUCTION_NAME
    end

    # @private
    def staging?
      environment == STAGING_NAME
    end
  end
end
