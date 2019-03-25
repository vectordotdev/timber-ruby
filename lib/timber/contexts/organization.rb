require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # @private
    class Organization < Context
      attr_reader :id, :name

      def initialize(attributes)
        @id = attributes[:id]
        @name = attributes[:name]
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= {
          organization: Util::NonNilHashBuilder.build do |h|
            h.add(:id, id)
            h.add(:name, name)
          end
        }
      end
    end
  end
end
