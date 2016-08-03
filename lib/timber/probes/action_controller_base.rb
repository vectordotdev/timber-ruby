module Timber
  module Probes
    # Wraps process_action so that we get *anu* logs written within the controller.
    # This is superior to using process_action in ActionController::LogSubscriber.
    class ActionControllerBase < Probe
      module InstanceMethods
        def process(*args)
          request_context      = Contexts::ActionControllerRequest.new(self)
          organization_context = Contexts::ActionControllerOrganization.new(self)
          user_context         = Contexts::ActionControllerUser.new(self)
          response_context     = Contexts::ActionControllerResponse.new(self)
          # The order is relevant here, request_context is higher in the hierarchy
          CurrentContext.add(request_context, organization_context, user_context, response_context) do
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
