require "timber/contexts/active_record_query/binds"

module Timber
  module Contexts
    class ActiveRecordQuery < Context
      VERSION = "1".freeze
      KEY_NAME = "ruby_active_record_query".freeze

      attr_reader :log_subscriber, :event
      property :binds, :connection_id, :sql, :statement_name, :transaction_id, :time_ms

      def initialize(log_subscriber, event)
        # Initialize should be as fast as possible since it is executed inline.
        # Hence the lazy methods below.
        @log_subscriber = log_subscriber
        @event = event
        super()
      end

      def binds
        @binds ||= payload[:binds] && Binds.new(log_subscriber, payload[:binds])
      end

      def connection_id
        @connection_id ||= payload[:connection_id].try(:to_s)
      end

      def sql
        @sql ||= payload[:sql].try(:strip)
      end

      def statement_name
        @statement_name ||= payload[:statement_name]
      end

      def transaction_id
        @transaction_id ||= event.transaction_id.try(:to_s)
      end

      def time_ms
        @time_ms ||= event.duration
      end

      private
        def payload
          event.payload
        end
    end
  end
end
