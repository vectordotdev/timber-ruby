module Timber
  module Contexts
    class ActionControllerRequest < Context
      VERSION = "1".freeze
      KEY_NAME = "ruby_action_controller_request".freeze

      property :action, :controller, :format

      def initialize(controller)
        @action = controller.action_name
        @controller = controller.class.name
        @format = controller.request.format.try(:ref)
        super()
      end
    end
  end
end
