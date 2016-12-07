module Timber
  module Probes
    # Responsible for automatically tracking controller call and http response events
    # for applications that use `ActionController`.
    class ActionControllerLogSubscriber < Probe
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