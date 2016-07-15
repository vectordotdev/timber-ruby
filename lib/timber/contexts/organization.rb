module Timber
  module Contexts
    class Organization < Context
      VERSION = "1".freeze
      KEY_NAME = "organization".freeze

      attr_reader :organization
      property :id, :name

      def initialize(organization)
        # Initialize should be as fast as possible since it is executed inline.
        # Hence the lazy methods below.
        @organization = organization
        super()
      end

      def id
        return @id if defined?(@id)
        @id = organization.respond_to?(:id) ? organization.id : nil
      end

      def name
        return @name if defined?(@name)
        @name = organization.respond_to?(:name) ? organization.name : nil
      end
    end
  end
end
