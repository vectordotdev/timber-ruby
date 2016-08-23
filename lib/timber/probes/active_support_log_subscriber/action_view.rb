module Timber
  module Probes
    class ActiveSupportLogSubscriber < Probe
      module ActionView
        def self.render_collection(_log_subscriber, event, &_block)
          wrap(event) { yield }
        end

        def self.render_partial(_log_subscriber, event, &_block)
          wrap(event) { yield }
        end

        def self.render_template(_log_subscriber, event, &_block)
          wrap(event) { yield }
        end

        private
          def self.wrap(event, &_block)
            context1 = Contexts::TemplateRenders::ActionView.new(event)
            context2 = Contexts::TemplateRenders::ActionViewSpecific.new(event)
            CurrentContext.add(context1, context2) { yield }
          end
      end
    end
  end
end