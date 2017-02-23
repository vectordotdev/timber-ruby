module Timber
  module Util
    # @private
    module Object
      # @private
      def self.try(object, method)
        if object == nil
          nil
        else
          object.send(method) rescue object
        end
      end
    end
  end
end