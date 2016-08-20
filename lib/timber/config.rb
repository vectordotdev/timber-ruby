module Timber
  class Config
    include Patterns::DelegatedSingleton

    attr_writer :application_key, :enabled, :logger

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
      @logger ||= InternalLogger.new(STDOUT)
    end
  end
end
