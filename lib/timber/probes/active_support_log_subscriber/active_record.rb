module Timber
  module Probes
    class ActiveSupportLogSubscriber < Probe
      module ActiveRecord
        def self.sql(log_subscriber, event, &block)
          context = Contexts::ActiveRecordQuery.new(log_subscriber, event)
          CurrentContext.add(context) { yield }
        end
      end
    end
  end
end