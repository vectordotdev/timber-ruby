module Timber
  module Contexts
    # The user context tracks the currently authenticated user.
    #
    # @note This is tracked automatically with the {Integrations::Rack::UserContext} rack
    #   middleware.
    class User < Context
      @keyspace = :user

      attr_reader :id, :name, :email

      def initialize(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
        @email = attributes[:email]
      end

      def as_json(_options = {})
        {id: Timber::Util::Object.try(id, :to_s), name: name, email: email}
      end
    end
  end
end