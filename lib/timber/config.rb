require "logger"
require "singleton"

module Timber
  class Config
    include Singleton

    attr_writer :logger

    class << self
      private
        def method_missing(name, *args, &block)
          instance.send(name, *args, &block)
        end
    end

    def logger?
      !@logger.nil?
    end

    def logger
      @logger ||= Logger.new(nil)
    end
  end
end
