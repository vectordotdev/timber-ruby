require "timber/contexts/active_record_query/binds"

module Timber
  module Contexts
    class ActiveRecordQuery < Context
      VERSION = "1".freeze
      KEY_NAME = "ruby_active_record_query".freeze

      property :binds, :connection_id, :sql, :statement_name, :transaction_id, :time_ms

      def initialize(event)
        payload = event.payload
        Config.logger.error payload[:binds].inspect
        @binds = payload[:binds] && Binds.new(payload[:binds])
        @connection_id = payload[:connection_id].try(:to_s)
        @sql = payload[:sql].try(:strip)
        @statement_name = payload[:statement_name]
        @transaction_id = event.transaction_id.try(:to_s)
        @time_ms = event.duration
        super()
      end
    end
  end
end
