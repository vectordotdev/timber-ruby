require "singleton"

module Timber
  # Interface for configuring Timber.
  #
  # @note If using rails this will be installed in the `config` object via `config.timber`.
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