module Timber
  module Probes
    class ActionController < Probe
      module InstanceMethods
        def process_action(*args)
          request_context = Contexts::ActionControllerRequest.new(self)
          organization_context = begin
            Contexts::ActionControllerOrganization.new(self)
          rescue Contexts::ActionControllerOrganization::OrganizationRequiredError
            nil
          end
          user_context = begin
            Contexts::ActionControllerUser.new(self)
          rescue Contexts::ActionControllerUser::UserRequiredError
            nil
          end
          # The order is relevant here, request_context is higher in the hierarchy
          CurrentContext.add(request_context, organization_context, user_context) do
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
        ::ActionController::Base.send(:include, InstanceMethods)
      end
    end
  end
end
