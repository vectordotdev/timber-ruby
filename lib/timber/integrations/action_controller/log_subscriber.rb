require "timber/integrator"

module Timber
  module Integrations
    module ActionController
      # Responsible for removing the default ActionController::LogSubscriber and installing
      # the TimberLogSubscriber
      #
      # @private
      class LogSubscriber < Integrator
        def initialize
          require "action_controller/log_subscriber"
          require "timber/integrations/action_controller/log_subscriber/timber_log_subscriber"
        rescue LoadError => e
          raise RequirementNotMetError.new(e.message)
        end

        def integrate!
          return true if Util::ActiveSupportLogSubscriber.subscribed?(:action_controller, TimberLogSubscriber)

          Util::ActiveSupportLogSubscriber.unsubscribe!(:action_controller, ::ActionController::LogSubscriber)
          TimberLogSubscriber.attach_to(:action_controller)
        end
      end
    end
  end
end