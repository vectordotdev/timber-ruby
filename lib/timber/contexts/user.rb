require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # The user context adds data about the currently authenticated user to your logs.
    # By adding this context all of your logs will contain user information. This allows
    # filter and tail logs by specific users.
    #
    # @note This is tracked automatically with the {Integrations::Rack::UserContext} rack
    #   middleware for supported authentication frameworks. See {Integrations::Rack::UserContext}
    #   for more details.
    class User < Context
      ID_MAX_BYTES = 256.freeze
      NAME_MAX_BYTES = 256.freeze
      EMAIL_MAX_BYTES = 256.freeze
      TYPE_MAX_BYTES = 256.freeze

      @keyspace = :user

      attr_reader :id, :name, :email, :type, :meta

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @id = normalizer.fetch(:id, :string, :limit => ID_MAX_BYTES)
        @name = normalizer.fetch(:name, :string, :limit => NAME_MAX_BYTES)
        @email = normalizer.fetch(:email, :string, :limit => EMAIL_MAX_BYTES)
        @type = normalizer.fetch(:type, :string, :limit => TYPE_MAX_BYTES)
        @meta = normalizer.fetch(:meta, :hash)
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:id, id)
          h.add(:name, name)
          h.add(:email, email)
          h.add(:type, type)
          h.add(:meta, meta)
        end
      end
    end
  end
end
