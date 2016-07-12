module Timber
  module ClassLevelInheritableAttributes
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def inheritable_attributes(*args)
        @inheritable_attributes_array ||= [:inheritable_attributes]
        @inheritable_attributes_array += args
        args.each do |arg|
          class_eval %(
            class << self; attr_accessor :#{arg} end
          )
        end
        @inheritable_attributes_array
      end

      def inherited(subclass)
        subclass.instance_variable_set(:"@inheritable_attributes_array", @inheritable_attributes_array)
        (@inheritable_attributes_array || []).each do |inheritable_attribute|
          instance_var = :"@#{inheritable_attribute}"
          subclass.instance_variable_set(instance_var, instance_variable_get(instance_var))
        end
      end
    end
  end
end
