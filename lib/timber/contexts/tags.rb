module Timber
  module Contexts
    # Adds unnamed tags to the context.
    #
    # **Warning:** It is highly recommend that you use custom contexts instead. As they are
    # more descriptive. This module exists primarily to support the ActiveSupport::TaggedLogging
    # antipattern.
    class Tags < Context
      @keyspace = :tags

      attr_reader :values

      def initialize(attributes)
        @values = attributes[:values] || raise(ArgumentError.new(":values is required"))
      end

      def as_json(_options = {})
        values
      end
    end
  end
end