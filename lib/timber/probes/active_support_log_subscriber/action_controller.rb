module Timber
  module Probes
    class ActiveSupportLogSubscriber < Probe
      module ActionController
        def self.process_action(_log_subscriber, event, &_block)
          context = CurrentContext.get(Contexts::HTTPResponses::ActionController)
          if context
            context.event = event
          end
          yield
        end
      end
    end
  end
end