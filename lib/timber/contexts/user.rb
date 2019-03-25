require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # @private
    class User < Context
      attr_reader :id, :name, :email

      def initialize(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
        @email = attributes[:email]
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= {
          user: Util::NonNilHashBuilder.build do |h|
            h.add(:id, id)
            h.add(:name, name)
            h.add(:email, email)
          end
        }
      end
    end
  end
end
