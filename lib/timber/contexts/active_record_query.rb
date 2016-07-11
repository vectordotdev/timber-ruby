module Timber
  module Contexts
    class ActiveRecordQuery < Context
      VERSION = "1".freeze
      KEY_NAME = "ruby_active_record_query".freeze

      property :connection_id, :transaction_id, :time_seconds

      def initialize(event)
        payload = event.payload
        @connection_id = payload[:connection_id]
        @transaction_id = payload[:transaction_id]
        @time_seconds = event.end - event.time
        super()
      end
    end
  end
end
