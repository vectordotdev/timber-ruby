module Timber
  module Events
    class Custom < Timber::Event
      attr_reader :type, :message, :data

      def initialize(attributes)
        @type = attributes[:type] || raise(ArgumentError.new(":type is required"))
        @message = attributes[:message] || raise(ArgumentError.new(":message is required"))
        @data = attributes[:data]
      end

      def to_hash
        {type => data}
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