module Timber
  # Base class for `Timber::Integrations::*`. Provides a common interface for all integrators.
  # An integrator is a single specific integration into a part of a library. See
  # {Integration} for higher library level integration settings.
  class Integrator
    # Raised when an integrators requirements are not met. For example, this will be raised
    # in the ActiveRecord integration if ActiveRecord is not available as a dependency in
    # the current application.
    class RequirementNotMetError < StandardError; end

    class << self
      attr_writer :enabled

      # Allows you to enable / disable specific integrations.
      #
      # @note Disabling specific low level integrations should only be needed for edge cases.
      #   If you want to disable integration with an entire library, we recommend doing so
      #   at a higher level. Ex: `Timber::Integrations::ActiveRecord.enabled = false`.
      #
      # @example
      #   Timber::Integrations::ActiveRecord::LogSubscriber.enabled = false
      def enabled?
        @enabled != false
      end

      # Convenience class level method that runs the integrator by instantiating a new
      # object and calling {#integrate!}. It also takes care to look at the if the integrator
      # is enabled, skipping it if not.
      def integrate!(*args)
        if !enabled?
          Config.instance.debug_logger.debug("#{name} integration disabled, skipping") if Config.instance.debug_logger
          return false
        end

        new(*args).integrate!
        Config.instance.debug_logger.debug("Integrated #{name}") if Config.instance.debug_logger
        true
      # RequirementUnsatisfiedError is the only silent failure we support
      rescue RequirementNotMetError => e
        Config.instance.debug_logger.debug("Failed integrating #{name}: #{e.message}") if Config.instance.debug_logger
        false
      end
    end

    # Abstract method that each integration must implement.
    def integrate!
      raise NotImplementedError.new
    end
  end
end
