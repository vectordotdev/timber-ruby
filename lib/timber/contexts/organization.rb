module Timber
  module Contexts
    class Organization < Context
      VERSION = "1".freeze
      KEY_NAME = "organization".freeze

      attr_reader :organization
      property :id, :name

      def id
        return @id if defined?(@id)
        @id = organization.respond_to?(:id) ? organization.id : nil
      end

      def name
        return @name if defined?(@name)
        @name = organization.respond_to?(:name) ? organization.name : nil
      end

      def valid?
        !organization.nil?
      end
    end
  end
end
