module Timber
  module Contexts
    class User < ObjectBased
      VERSION = "1".freeze
      KEY_NAME = "user".freeze

      property :email, :id, :name

      private
        def set_properties(object)
          super(object, properties)
          @id = @id.to_s unless @id.nil? # ensure id is a string, we can't assume everyone uses integers
        end
    end
  end
end
