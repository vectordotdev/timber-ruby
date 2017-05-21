require "singleton"

module Timber
  class Config
    # Configuration specifically for integrations. This class can be accessed from the
    # main `Timber::Config` class.
    #
    # Note: this class is separated from the actual configuration classes to decouple
    # configuration from the internal class design. This makes it easier to be backwards
    # compatible should class names change.
    #
    # @example Rails example
    #   config.timber.integrations.active_record.enabled = false
    # @example Everything else
    #   config = Timber::Config.instance
    #   config.integrations.active_record.enabled = false
    class Integrations
      include Singleton

      attr_writer :append_metadata, :debug_logger, :header_filters, :http_body_limit, :logger

    end
  end
end