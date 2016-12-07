module Timber
  module Events
    class SQLQuery < Timber::Event
      attr_reader :sql, :time_ms, :message

      def initialize(attributes)
        @sql = attributes[:sql] || raise(ArgumentError.new(":sql is required"))
        @time_ms = attributes[:time_ms] || raise(ArgumentError.new(":time_ms is required"))
        @message = attributes[:message] || raise(ArgumentError.new(":message is required"))
      end

      def to_hash
        {sql: sql, time_ms: time_ms}
      end
      alias to_h to_hash

      def as_json(_options = {})
        {:sql_query => to_hash}
      end
    end
  end
end