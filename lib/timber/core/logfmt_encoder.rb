module Timber
  module Core
    # Encodes a hash into a logfmt string
    module LogfmtEncoder
      KEY_DELIMITER = ".".freeze
      PAIR_DELIMITER = " ".freeze

      def self.encode(hash, ancestors = [])
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
          string_key = key.to_s
          string_key.include?(KEY_DELIMITER) ? string_key.inspect : string_key
        end

        def self.encode_value(value)
          value.to_json
        end
    end
  end
end