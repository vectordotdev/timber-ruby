module Timber
  module Core
    # Encodes a hash into a logfmt string
    module LogfmtEncoder
      KEY_DELIMITER = ".".freeze
      PAIR_DELIMITER = " ".freeze
      SPECIAL_CHARACTERS = [" ", "\\\""]

      def self.encode(hash, ancestors = [])
        if !hash.is_a?(Hash)
          raise ArgumentError.new("hash must be a Hash")
        end
        hash.collect do |key, value|
          keys = ancestors + [key]
          if value.is_a?(Hash)
            encode(value, keys)
          else
            "#{encode_keys(keys)}=#{encode_value(value)}"
          end
        end.flatten.join(PAIR_DELIMITER)
      end

      private
        def self.encode_keys(keys)
          keys.collect do |key|
            encode_key(key)
          end.join(KEY_DELIMITER)
        end

        def self.encode_key(key)
          stripdown(key.to_json, [KEY_DELIMITER])
        end

        def self.encode_value(value)
          stripdown(value.to_json)
        end

        def self.stripdown(value, special_characters = [])
          if value.start_with?("\"") && value.end_with?("\"")
            quoteable = (SPECIAL_CHARACTERS + special_characters).any? { |c| value.include?(c) }
            if !quoteable
              value[0] = ''
              value[-1] = ''
            end
          end
          value
        end
    end
  end
end