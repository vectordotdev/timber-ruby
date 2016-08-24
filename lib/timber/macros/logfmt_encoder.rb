module Timber
  module Macros
    # Encodes a hash into a simple logfmt string.
    #
    # A couple of important points:
    #
    # 1. This module is designed to be fast, as it is executed inline with
    #    each log line.
    # 2. It makes assumptions about the hash structure, and is designed
    #    specifically for Timber. We can reduce the edge cases and improve
    #    performance drastically.
    class LogfmtEncoder
      ARRAY_DELIMITER = ",".freeze
      ARRAY_END = "]".freeze
      ARRAY_START = "[".freeze
      ESCAPE = "\\".freeze
      KEY_DELIMITER = ".".freeze
      KEY_VALUE_DELIMITER = "=".freeze
      PAIR_DELIMITER = " ".freeze
      STRING_WRAPPER = "\"".freeze
      SPECIAL_KEY_CHARACTERS = [KEY_DELIMITER, PAIR_DELIMITER].freeze
      SPECIAL_VALUE_CHARACTERS = [ARRAY_DELIMITER, ARRAY_END, ARRAY_START, ESCAPE, PAIR_DELIMITER, STRING_WRAPPER].freeze

      def self.encode(hash, ancestors = [])
        if !hash.is_a?(Hash)
          raise ArgumentError.new("hash must be a Hash")
        end
        items = hash.collect do |key, value|
          keys = ancestors + [key]
          if value.is_a?(Hash)
            encode(value, keys)
          else
            "#{encode_keys(keys)}#{KEY_VALUE_DELIMITER}#{encode_value(value)}"
          end
        end.flatten
        join(*items)
      end

      def self.join(*items)
        items.join(PAIR_DELIMITER)
      end

      private
        def self.encode_keys(keys)
          keys.collect { |key| encode_key(key) }.join(KEY_DELIMITER)
        end

        def self.encode_key(key)
          key = key.to_s
          if SPECIAL_KEY_CHARACTERS.any? { |c| key.include?(c) }
            escape(key)
          else
            key
          end
        end

        def self.encode_value(value)
          if value.is_a?(Array)
            values = value.collect { |v| encode_value(v) }.join(ARRAY_DELIMITER)
            "#{ARRAY_START}#{values}#{ARRAY_END}"
          elsif value.is_a?(String) && SPECIAL_VALUE_CHARACTERS.any? { |c| value.include?(c) }
            escape(value)
          else
            value
          end
        end

        def self.escape(value)
          # Simple gsub that is better for performance, we do not need to handle
          # all of the edgecases that to_json handled. #to_json is also much slower.
          new_value = value.gsub(STRING_WRAPPER, "#{ESCAPE}#{STRING_WRAPPER}")
          new_value.gsub!(ESCAPE, "#{ESCAPE}#{ESCAPE}")
          "#{STRING_WRAPPER}#{new_value}#{STRING_WRAPPER}"
        end
    end
  end
end