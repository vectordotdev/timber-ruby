module Timber
  module Contexts
    # Custom contexts allow you to add application specific context not covered elsewhere.
    #
    # @example Adding a context
    #   logger.with_context(build: {version: "1.0.0"}) do
    #     # ... anything logged here will have the context ...
    #   end
    class Custom < Context
      @keyspace = :custom

      attr_reader :type, :data

      def initialize(attributes)
        @type = attributes[:type] || raise(ArgumentError.new(":type is required"))
        @data = attributes[:data] || raise(ArgumentError.new(":data is required"))
      end

      def as_json(_options = {})
        {Timber::Util::Object.try(type, :to_sym) => data}
      end
    end
  end
end