require "logger"

module Timber
  class Config
    include Patterns::DelegatedSingleton

    attr_writer :logger

    def logger?
      !@logger.nil?
    end

    def logger
      @logger ||= Logger.new(nil)
    end
  end
end
