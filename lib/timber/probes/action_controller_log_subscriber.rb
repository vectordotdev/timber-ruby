module Timber
  module Probes
    class ActionControllerLogSubscriber < Probe #:nodoc:
      def initialize
        require "action_controller/log_subscriber"
        require "timber/probes/action_controller_log_subscriber/log_subscriber"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if Util::ActiveSupportLogSubscriber.subscribed?(:action_controller, LogSubscriber)
        Util::ActiveSupportLogSubscriber.unsubscribe(:action_controller, ::ActionController::LogSubscriber)
        LogSubscriber.attach_to(:action_controller)
      end
    end
  end
end