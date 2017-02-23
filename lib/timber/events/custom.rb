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
        @type = attributes[:type] || raise(ArgumentError.new(":type is required"))
        @message = attributes[:message] || raise(ArgumentError.new(":message is required"))
        @data = attributes[:data]
      end

      def to_hash
        {Timber::Util::Object.try(type, :to_sym) => data}
      end
      alias to_h to_hash

      def as_json(_options = {})
        {:custom => to_hash}
      end

      def to_json(options = {})
        as_json().to_json(options)
      end
    end
  end
end