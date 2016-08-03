module Timber
  module Probes
    class ActiveSupportLogSubscriber < Probe
      module ActionView
        def self.render_collection(_log_subscriber, event, &block)
          context = Contexts::ActionViewTemplateRender.new(event)
          CurrentContext.add(context) { yield }
        end

        def self.render_partial(_log_subscriber, event, &block)
          context = Contexts::ActionViewTemplateRender.new(event)
          CurrentContext.add(context) { yield }
        end

        def self.render_template(_log_subscriber, event, &block)
          context = Contexts::ActionViewTemplateRender.new(event)
          CurrentContext.add(context) { yield }
        end
      end
    end
  end
end