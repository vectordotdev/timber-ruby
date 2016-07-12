module Timber
  module Probes
    class ActionView < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            alias_method :old_render_template, :render_template

            def render_template(event)
              context = Contexts::ActionViewTemplateRender.new(event)
              CurrentContext.add(context) do
                old_render_template(event)
              end
            end
          end
        end
      end

      def initialize
        require "action_view/log_subscriber"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        ::ActionView::LogSubscriber.send(:include, InstanceMethods)
      end
    end
  end
end
