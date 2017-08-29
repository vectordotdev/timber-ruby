require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # The session context adds the current session ID to your logs. This allows you
    # to tail and filter logs by specific session IDs. Moreover, it gives you a unique
    # identifier to report on user activity by session. This way your logs can tell the
    # story of how many time a user has engaged your site.
    #
    # @note This is tracked automatically with the {Integrations::Rack::SessionContext} rack
    #   middleware.
    class Session < Context
      @keyspace = :session

      attr_reader :id

      def initialize(attributes)
        @id = Timber::Util::Object.try(attributes[:id], :to_s) || raise(ArgumentError.new(":id is required"))
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {id: id}
      end
    end
  end
end