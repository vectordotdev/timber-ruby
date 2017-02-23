module Timber
  module Util
    # @private
    module Hash
      extend self

      def deep_compact(hash)
        new_hash = {}

        hash.each do |k, v|
          v = if v.is_a?(::Hash)
            deep_compact(v)
          else
            v
          end

          if v != nil && v != "" && v != {} && v != []
            new_hash[k] = v
          end
        end

        new_hash
      end
    end
  end
end