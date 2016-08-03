module Timber
  module Contexts
    class ActionControllerOrganization < Organization
      DEFAULT_METHOD_NAME = :current_organization.freeze

      class << self
        attr_writer :method_name

        def method_name
          @method_name ||= DEFAULT_METHOD_NAME
        end
      end

      attr_reader :controller

      def initialize(controller)
        @controller = controller
        super()
      end

      private
        def method_name
          self.class.method_name
        end

        def organization
          controller.respond_to?(method_name, true) ? controller.send(method_name) : nil
        end
    end
  end
end
