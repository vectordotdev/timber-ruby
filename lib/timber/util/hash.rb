module Timber
  module Util
    # @private
    module Hash
      BINARY_LIMIT_THRESHOLD = 1_000.freeze
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

      # Recursively traverses a hash, dropping non-JSON compatible types.
      # If the string is a binary, and it is > 1000 characters, it is dropped.
      # We are assuming it represents file contents that should not be included
      # in the logs.
      def jsonify(hash)
        deep_reduce(hash) do |k, v, h|
          if v.is_a?(String)
            if v.encoding == ::Encoding::ASCII_8BIT
              # Only keep binary values less than a certain size. Sizes larger than this
              # are almost always file uploads and data we do not want to log.
              if v.length < BINARY_LIMIT_THRESHOLD
                # Attempt to safely encode the data to UTF-8
                encoded_value = encode_string(v)
                if !encoded_value.nil?
                  h[k] = encoded_value
                end
              end
            elsif v.encoding != ::Encoding::UTF_8
              h[k] = encode_string(v)
            else
              h[k] = v
            end
          elsif is_a_primitive_type?(v)
            # Keep all other primitive types
            h[k] = v
          end
        end
      end

      # Replaces matching keys with a `[Sanitized]` value.
      def sanitize_keys(hash, keys_to_sanitize)
        hash.each_with_object({}) do |(k, v), h|
          k = k.to_s.downcase
          if keys_to_sanitize.include?(k)
            h[k] = SANITIZED_VALUE
          else
            h[k] = v
          end
        end
      end

      private
        # Attempts to encode a non UTF-8 string into UTF-8, discarding invalid characters.
        # If it fails, a nil is returned.
        def encode_string(string)
          string.encode('UTF-8', {
            :invalid => :replace,
            :undef   => :replace,
            :replace => '?'
          })
        rescue Exception
          nil
        end

        # We use is_a? because it accounts for inheritance.
        def is_a_primitive_type?(v)
          v.is_a?(Array) || v.is_a?(Integer) || v.is_a?(Float) || v.is_a?(TrueClass) ||
            v.is_a?(FalseClass) || v.is_a?(String) || v.is_a?(Time) || v.is_a?(::Hash)
        end
    end
  end
end
