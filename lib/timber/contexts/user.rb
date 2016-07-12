module Timber
  module Contexts
    class User < ObjectBased
      VERSION = "1".freeze
      KEY_NAME = "user".freeze

      property :email, :id, :name

      private
        def set_properties(object)
          super(object, properties)
        end
    end
  end
end
