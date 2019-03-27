require 'timber/util'
require 'timber/event'

module Timber
  module Events
    # @private
    class SQLQuery < Timber::Event
      attr_reader :sql, :duration_ms, :message

      def initialize(attributes)
        @sql = attributes[:sql]
        @duration_ms = attributes[:duration_ms]
        @message = attributes[:message]
      end

      def to_hash
        {
          sql_query_executed: Util::NonNilHashBuilder.build do |h|
            h.add(:sql, sql)
            h.add(:duration_ms, duration_ms)
          end
        }
      end
    end
  end
end
