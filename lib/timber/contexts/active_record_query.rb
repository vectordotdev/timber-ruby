require "timber/contexts/active_record_query/binds"

module Timber
  module Contexts
    class ActiveRecordQuery < Context
      VERSION = "1".freeze
      KEY_NAME = "ruby_active_record_query".freeze

      property :binds, :connection_id, :sql, :statement_name, :transaction_id, :time_ms

      def initialize(log_subscriber, event)
        payload = event.payload
        @binds = Binds.new(log_subscriber, payload[:binds])
        Config.logger.error "\n\n\n\n------------------\n\n" + payload[:binds].inspect + "\n\n" + @binds.send(:values_array).inspect + "\n\n------------------\n\n\n\n\n"
        @connection_id = payload[:connection_id].try(:to_s)
        @sql = payload[:sql].try(:strip)
        Config.logger.error @sql.inspect
        Config.logger.error @sql.inspect
        @statement_name = payload[:statement_name]
        @transaction_id = event.transaction_id.try(:to_s)
        @time_ms = event.duration
        super()
      end
    end
  end
end
