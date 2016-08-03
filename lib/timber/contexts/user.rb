module Timber
  module Contexts
    class User < Context
      VERSION = "1".freeze
      KEY_NAME = "user".freeze

      attr_reader :user
      property :email, :id, :name

      def email
        return @email if defined?(@email)
        @email = user.respond_to?(:email) ? user.email : nil
      end

      def id
        return @id if defined?(@id)
        @id = user.respond_to?(:id) ? user.id : nil
      end

      def name
        return @name if defined?(@name)
        @name = user.respond_to?(:name) ? user.name : nil
      end

      def valid?
        !user.nil?
      end
    end
  end
end
