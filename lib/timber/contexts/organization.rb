module Timber
  module Contexts
    # The organization context tracks the organization of the currently
    # authenticated user.
    #
    # You will want to add this context at the time you determine
    # the organization a user belongs to, typically in the authentication
    # flow.
    #
    # Example:
    #
    #   organization_context = Timber::Contexts::Organization.new(id: "abc1234", name: "Timber Inc")
    #   Timber::CurrentContext.with(organization_context) do
    #     # Logging will automatically include this context
    #     logger.info("This is a log message")
    #   end
    #
    class Organization < Context
      attr_reader :id, :name

      def initialize(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
      end

      def keyspace
        :organization
      end

      def as_json(_options = {})
        {id: id, name: name}
      end
    end
  end
end