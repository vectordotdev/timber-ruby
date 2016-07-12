module Timber
  module Contexts
    class ActionControllerUser < User
      DEFAULT_METHOD_NAME = :current_user.freeze

      class << self
        attr_writer :method_name

        def method_name
          @method_name ||= DEFAULT_METHOD_NAME
        end
      end

      def initialize(controller)
        object = controller.respond_to?(self.class.method_name, true) ?
          controller.send(self.class.method_name) :
          nil
        super(object)
      end
    end
  end
end
