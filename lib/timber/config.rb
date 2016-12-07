require "singleton"

module Timber
  class Config
    include Singleton

    attr_writer :logger

    # Set a logger to view internal Timber library log message.
    # Useful for debugging. Defaults to `::Logger.new(nil)`.
    def logger
      @logger ||= Logger.new(nil)
    end
  end
end