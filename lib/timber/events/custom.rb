require "timber/event"
require "timber/util"

module Timber
  module Events
    # Allows for custom events that aren't covered elsewhere.
    #
    # Custom events can be used to encode information about events that are central
    # to your line of business like receiving credit card payments, saving a draft of a post,
    # or changing a user's password.
    #
    # For examples of logging custom events see {Logger}.
    class Custom < Timber::Event
      attr_reader :type, :message, :data

      # Instantiates a new custom event that can be logged. See {Logger} for examples
      # on logging custom events.
      #
      # @param [Hash] attributes the options to create a custom event with.
      # @option attributes [Symbol] :type *required* The custom event type. This should be in
      #   snake case. Example: `:my_custom_event`.
      # @option attributes [String] :message *required* The message to be logged.
      # @option attributes [Hash] :data A hash of JSON encodable data to be stored with the
      #   log line.
      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @type = normalizer.fetch!(:type, :symbol)
        @message = normalizer.fetch!(:message, :string)

        data = normalizer.fetch(:data, :hash, default: {})

        if !data.nil? && data[:time_ms].is_a?(Time)
          data[:time_ms] = Timer.duration_ms(data[:time_ms])
          @message << " in #{data[:time_ms]}ms"
        end

        @data = data
      end

      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(type, data)
        end
      end
      alias to_h to_hash

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {:custom => to_hash}
      end
    end
  end
end
