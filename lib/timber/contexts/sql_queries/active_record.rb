module Timber
  module Contexts
    module SQLQueries
      class ActiveRecord < SQLQuery
        attr_reader :log_subscriber, :event

        def initialize(log_subscriber, event)
          # Initialize should be as fast as possible since it is executed inline.
          # Hence the lazy methods below.
          @log_subscriber = log_subscriber
          @event = event
          super()
        end

        def sql
          @sql ||= payload[:sql].try(:strip)
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
end
