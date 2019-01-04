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
      ID_MAX_BYTES = 256.freeze

      @keyspace = :session

      attr_reader :id

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @id = normalizer.fetch!(:id, :string, :limit => ID_MAX_BYTES)
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:id, id)
        end
      end
    end
  end
end
