module Timber
  module Contexts
    # The session context tracks the current session for the given user.
    #
    # @note This is tracked automatically with the `Integrations::Rack::SessionContext` rack
    #   middleware.
    class Session < Context
      @keyspace = :session

      attr_reader :id

      def initialize(attributes)
        @id = attributes[:id] || raise(ArgumentError.new(":id is required"))
      end

      def as_json(_options = {})
        {id: Timber::Util::Object.try(id, :to_s)}
      end
    end
  end
end