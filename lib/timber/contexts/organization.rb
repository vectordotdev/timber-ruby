require "timber/context"
require "timber/util"

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
    #   logger.with_context(organization_context) do
    #     # Logging will automatically include this context
    #     logger.info("This is a log message")
    #   end
    #
    class Organization < Context
      ID_MAX_BYTES = 256.freeze
      NAME_MAX_BYTES = 256.freeze

      @keyspace = :organization

      attr_reader :id, :name

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @id = normalizer.fetch(:id, :string, :limit => ID_MAX_BYTES)
        @name = normalizer.fetch(:name, :string, :limit => NAME_MAX_BYTES)
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:id, id)
          h.add(:name, name)
        end
      end
    end
  end
end
