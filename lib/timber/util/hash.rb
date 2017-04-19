module Timber
  module Util
    # @private
    module Hash
      SANITIZED_VALUE = '[sanitized]'.freeze

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