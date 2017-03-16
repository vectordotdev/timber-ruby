module Timber
  # Base class for `Timber::Probes::*`.
  # @private
  class Probe
    class RequirementNotMetError < StandardError; end

    class << self
      def insert!(*args)
        new(*args).insert!
        Config.instance.debug_logger.debug("Inserted probe #{name}") if Config.instance.debug_logger
        true
      # RequirementUnsatisfiedError is the only silent failure we support
      rescue RequirementNotMetError => e
        Config.instance.debug_logger.debug("Failed inserting probe #{name}: #{e.message}") if Config.instance.debug_logger
        false
      end
    end

    def insert!
      raise NotImplementedError.new
    end
  end
end