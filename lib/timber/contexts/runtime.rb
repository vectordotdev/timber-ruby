require "timber/context"

module Timber
  module Contexts
    # @private
    class Runtime < Context
      attr_reader :thread_id

      def initialize(attributes)
        @thread_id = attributes[:thread_id]
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= {
          runtime: Util::NonNilHashBuilder.build do |h|
            h.add(:thread_id, thread_id)
          end
        }
      end
    end
  end
end
