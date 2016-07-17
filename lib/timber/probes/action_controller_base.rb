module Timber
  module Probes
    # Wraps process_action so that we get *anu* logs written within the controller.
    # This is superior to using process_action in ActionController::LogSubscriber.
    class ActionControllerBase < Probe
      module InstanceMethods
        def process(*args)
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

        private
          # Adding additional data here. I don't want to alter the essence of the payload
          # object by including complex objects, so we include them here.
          def append_info_to_payload(payload)
            super
            payload[:cache_controler] = response.cache_control
            payload[:content_disposition] = response.headers['Content-Disposition']
            payload[:content_length] = response.content_length
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
