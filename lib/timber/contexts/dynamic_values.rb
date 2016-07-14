require "bigdecimal"
require "date"

module Timber
  module Contexts
    class DynamicValues
      BOOLEAN_TYPES = [FalseClass, TrueClass].freeze
      DATE_TYPES    = [Date, Time].freeze
      FLOAT_TYPES   = [BigDecimal, Float].freeze
      INTEGER_TYPES = [Fixnum].freeze
      NIL_TYPES     = [NilClass].freeze
      STRING_TYPES  = [String].freeze

      attr_reader :object

      def initialize(object)
        if object.nil?
          raise ArgumentError.new("object cannot be nil")
        end
        @object = object
      end

      def as_json
        @as_json ||= case object
        when Hash
          object.collect do |key, value|
            to_item(key, value)
          end
        end
      end

      def to_json(*args)
        # Note: this is run in the background thread, hence the hash creation.
        @json ||= as_json.to_json(*args)
      end

      private
        def to_item(name, value)
          {
            :name  => name,
            :type  => type(value),
            :value => value
          }
        end

        def type(value)
          # Using is_a? because it checks the entire hierarchy, unlike a case statement.
          if BOOLEAN_TYPES.any? { |type| value.is_a?(type) }
            APISettings::BOOLEAN_TYPE
          elsif DATE_TYPES.any? { |type| value.is_a?(type) }
            APISettings::DATE_TYPE
          elsif FLOAT_TYPES.any? { |type| value.is_a?(type) }
            APISettings::FLOAT_TYPE
          elsif INTEGER_TYPES.any? { |type| value.is_a?(type) }
            APISettings::INTEGER_TYPE
          elsif NIL_TYPES.any? { |type| value.is_a?(type) }
            APISettings::NIL_TYPE
          else
            APISettings::STRING_TYPE
          end
        end
    end
  end
end
