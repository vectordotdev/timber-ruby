module Timber
  module Probes
    # Wraps process_action so that we get *anu* logs written within the controller.
    # This is superior to using process_action in ActionController::LogSubscriber.
    class ActionControllerBase < Probe
      module InstanceMethods
        def process(*args)
          request_context      = Contexts::HTTPRequests::ActionControllerSpecific.new(self)
          #organization_context = Contexts::Organizations::ActionController.new(self)
          #user_context         = Contexts::Users::ActionController.new(self)
          response_context     = Contexts::HTTPResponses::ActionController.new(self)
          # The order is relevant here, request_context is higher in the hierarchy
          CurrentContext.add(request_context, response_context) do
            super
          end
        end
      end

      def initialize
        require "action_controller"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if ::ActionController::Base.include?(InstanceMethods)
        ::ActionController::Base.send(:include, InstanceMethods)
      end
    end
  end
end
