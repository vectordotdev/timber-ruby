require "logger"

module Timber
  class Config
    include Patterns::DelegatedSingleton

    def set(&block)
      yield self
    end

    #
    # enabled
    #

    def enabled=(value)
      @enabled = value
    end

    def enabled
      return @enabled if defined?(@enabled)
      @enabled = true
    end

    def enabled?
      enabled == true
    end

    #
    # application_key
    #

    def application_key=(value)
      @application_key = value
    end

    def application_key
      @application_key
    end

    #
    # logger
    #

    # Set a customer logger that the Timber library will use.
    def logger=(value)
      @logger = value
    end

    # The logger that the Timber library will use.
    # Note: each framework resets the default logger
    # unless you explicitly set it as part of configuration.
    def logger
      @logger ||= Logger.new(STDOUT)
    end

    #
    # log_truck_enabled
    #

    def log_truck_enabled=(value)
      @log_truck_enabled = value
    end

    def log_truck_enabled
      return @log_truck_enabled if defined?(@log_truck_enabled)
      @log_truck_enabled = true
    end

    def log_truck_enabled?
      log_truck_enabled == true
    end

    #
    # resetting
    #

    def reset!(name)
      remove_instance_variable(:"@#{name}") if instance_variable_defined?(:"@#{name}")
    end
  end
end
