require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # @private
    class Session < Context
      attr_reader :id

      def initialize(attributes)
        @id = attributes[:id]
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= {
          session: Util::NonNilHashBuilder.build do |h|
            h.add(:id, id)
          end
        }
      end
    end
  end
end
