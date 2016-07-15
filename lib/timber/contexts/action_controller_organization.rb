module Timber
  module Contexts
    class ActionControllerOrganization < Organization
      class OrganizationRequiredError < StandardError; end

      DEFAULT_METHOD_NAME = :current_organization.freeze

      class << self
        attr_writer :method_name

        def method_name
          @method_name ||= DEFAULT_METHOD_NAME
        end
      end

      def initialize(controller)
        organization = controller.respond_to?(self.class.method_name, true) ?
          controller.send(self.class.method_name) :
          nil
        if organization.nil?
          raise OrganizationRequiredError.new
        end
        super(organization)
      end
    end
  end
end
