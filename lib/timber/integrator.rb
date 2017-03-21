module Timber
  # Base class for `Timber::Integrations::*`.
  #
  # @private
  class Integrator
    class RequirementNotMetError < StandardError; end

    class << self
      def integrate!(*args)
        new(*args).integrate!
        Config.instance.debug_logger.debug("Integrated #{name}") if Config.instance.debug_logger
        true
      # RequirementUnsatisfiedError is the only silent failure we support
      rescue RequirementNotMetError => e
        Config.instance.debug_logger.debug("Failed integrating #{name}: #{e.message}") if Config.instance.debug_logger
        false
      end
    end

    def integrate!
      raise NotImplementedError.new
    end
  end
end