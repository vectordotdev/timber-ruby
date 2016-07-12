module Timber
  module Contexts
    class Organization < ObjectBased
      VERSION = "1".freeze
      KEY_NAME = "organization".freeze

      property :id, :name

      private
        def set_properties(object)
          super(object, properties)
        end
    end
  end
end
