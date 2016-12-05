module Timber
  class Config
    include Singleton

    attr_writer :enabled, :logger

    def enabled
      return @enabled if defined?(@enabled)
      @enabled = true
    end

    def enabled?
      enabled == true
    end

    def logger
      @logger ||= Logger.new(nil)
    end
  end
end