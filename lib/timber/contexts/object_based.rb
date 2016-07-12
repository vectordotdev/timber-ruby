module Timber
  module Contexts
    class ObjectBased < Context
      class ObjectRequiredError < StandardError; end

      class << self
        attr_reader :after_initialize

        def after_initialize(&block)
          @after_initialize = block
        end
      end

      def initialize(object)
        if object.nil?
          raise ObjectRequiredError.new("An object is required to create this context")
        end
        set_properties(object)
        self.class.after_initialize.call(self, identity_object) if self.class.after_initialize
        super()
      end

      private
        def set_properties(object, properties)
          properties.each do |property|
            set_property(object, property)
          end
        end

        def set_property(object, property)
          if object.respond_to?(property)
            instance_variable_set(:"@#{property}", object.send(property))
          end
        end
    end
  end
end
