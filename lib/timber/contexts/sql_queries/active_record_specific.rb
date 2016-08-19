require "timber/contexts/sql_queries/active_record_specific/binds"

module Timber
  module Contexts
    module SQLQueries
      # Because this is a sub context we extend Context
      class ActiveRecordSpecific < Context
        PATH = "#{SQLQuery._root_key}.active_record"
        ROOT_KEY = :active_record.freeze
        VERSION = 1.freeze

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
            @json_payload ||= DeepMerger.merge(super, {
              SQLQuery._root_key => {
                _root_key => {
                  :binds => binds,
                  :connection_id => connection_id,
                  :statement_name => statement_name,
                  :transaction_id => transaction_id
                }
              }
            })
          end

          def payload
            event.payload
          end
      end
    end
  end
end
