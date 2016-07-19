require "logger"

module Timber
  class Config
    include Patterns::DelegatedSingleton

    attr_writer :application_key, :enabled, :logger, :log_truck_enabled, :monitor

    def application_key
      @application_key ||= ENV['TIMBER_KEY']
    end

    def enabled
      return @enabled if defined?(@enabled)
      @enabled = true
    end

    def enabled?
      enabled == true
    end

    # Internal logger for the Timber library
    def logger
      @logger ||= ::Logger.new(STDOUT)
    end

    def log_truck_enabled
      return @log_truck_enabled if defined?(@log_truck_enabled)
      @log_truck_enabled = true
    end

    def log_truck_enabled?
      log_truck_enabled == true
    end

    def monitor
      @monitor ||= []
    end

    def reset!(name)
      remove_instance_variable(:"@#{name}") if instance_variable_defined?(:"@#{name}")
    end
  end
end
