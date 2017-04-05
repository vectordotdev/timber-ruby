module Timber
  module Util
    # @private
    module Object
      # @private
      def self.try(object, method, *args)
        if object == nil
          nil
        else
          object.send(method, *args) rescue object
        end
      end
    end
  end
end