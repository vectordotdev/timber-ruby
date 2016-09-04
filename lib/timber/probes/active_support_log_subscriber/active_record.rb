module Timber
  module Probes
    class ActiveSupportLogSubscriber < Probe
      module ActiveRecord
        def self.sql(log_subscriber, event, &_block)
          Config.logger.warn("Adding sql context for #{event.payload[:sql]}")
          context1 = Contexts::SQLQueries::ActiveRecord.new(log_subscriber, event)
          context2 = Contexts::SQLQueries::ActiveRecordSpecific.new(log_subscriber, event)
          CurrentContext.add(context1, context2) { yield }
        end
      end
    end
  end
end