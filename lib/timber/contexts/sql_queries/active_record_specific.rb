require "timber/contexts/sql_queries/active_record_specific/binds"

module Timber
  module Contexts
    module SQLQueries
      # Because this is a sub context we extend Context
      class ActiveRecordSpecific < Context
        ROOT_KEY = :active_record.freeze
        VERSION = 1.freeze

        class << self
          def json_shell(&block)
            SQLQuery.json_shell { super }
          end
        end

        attr_reader :log_subscriber, :event

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

        def statement_name
          @statement_name ||= payload[:statement_name]
        end

        def transaction_id
          @transaction_id ||= event.transaction_id.try(:to_s)
        end

        private
          def json_payload
            @json_payload ||= Macros::DeepMerger.merge({
              :binds => binds.as_json,
              :connection_id => connection_id,
              :statement_name => statement_name,
              :transaction_id => transaction_id
            }, super).freeze
          end

          def payload
            event.payload
          end
      end
    end
  end
end
