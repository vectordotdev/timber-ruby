module Timber
  module Probes
    class ActiveSupportLogSubscriber < Probe
      module ActionController
        def self.process_action(_log_subscriber, event, &_block)
          if context = CurrentContext.get(Contexts::HTTPResponses::ActionController)
            context.event = event
          end
          yield
        end
      end
    end
  end
end