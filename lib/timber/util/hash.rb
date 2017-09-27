module Timber
  module Util
    # @private
    module Hash
      SANITIZED_VALUE = '[sanitized]'.freeze

      extend self

      # Deeply reduces a hash into a new hash, passing the current key, value,
      # and accumulated map up to that point. This allows the caller to
      # conditionally rebuild the hash.
      def deep_reduce(hash, &block)
        new_hash = {}

        hash.each do |k, v|
          v = if v.is_a?(::Hash)
            deep_reduce(v, &block)
          else
            v
          end

          block.call(k, v, new_hash)
        end

        new_hash
      end

      def sanitize(hash, keys_to_sanitize)
        hash.each_with_object({}) do |(k, v), h|
          k = k.to_s.downcase
          if keys_to_sanitize.include?(k)
            h[k] = SANITIZED_VALUE
          else
            h[k] = v
          end
        end
      end
    end
  end
end