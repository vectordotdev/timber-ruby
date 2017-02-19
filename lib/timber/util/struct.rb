module Timber
  module Util
    # @private
    module Struct
      extend self

      def to_hash(struct)
        h = {}
        struct.each_pair do |k ,v|
          h[k] = v
        end
        h
      end
    end
  end
end