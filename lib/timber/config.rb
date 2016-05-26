require "logger"

module Timber
  class Config
    include Patterns::DelegatedSingleton

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

    def application_id=(value)
      @application_id = value
    end

    def application_id
      @application_id
    end

    def application_key=(value)
      @application_key = value
    end

    def application_key
      @application_key
    end

    def reset!
      instance_variables.each do |ivar|
        remove_instance_variable(ivar)
      end
    end
  end
end
