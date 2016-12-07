module Timber
  module Util
    # @private
    module Hash
      extend self

      def compact(hash)
        hash.select do |k, v|
          v != nil && v != {} && v != []
        end
      end
    end
  end
end