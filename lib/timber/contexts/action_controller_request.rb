module Timber
  module Contexts
    class ActionControllerRequest < Context
      VERSION = "1".freeze
      KEY_NAME = "ruby_action_controller_request".freeze

      attr_reader :controller_obj
      property :action, :controller, :format

      def initialize(controller_obj)
        # Initialize should be as fast as possible since it is executed inline.
        # Hence the lazy methods below.
        @controller_obj = controller_obj
        super()
      end

      def action
        @action ||= controller_obj.action_name
      end

      def controller
        @controller ||= controller_obj.class.name
      end

      def format
        @format ||= controller_obj.request.format.try(:ref)
      end
    end
  end
end
