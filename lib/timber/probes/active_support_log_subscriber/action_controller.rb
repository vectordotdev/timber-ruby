module Timber
  module Probes
    class ActiveSupportLogSubscriber < Probe
      module ActionController
        def self.process_action(_log_subscriber, event, &block)
          if context = CurrentContext.get(Contexts::ActionControllerResponse)
            context.event = event
          end
          yield
        end
      end
    end
  end
end