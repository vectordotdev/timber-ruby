module Timber
  module Probes
    class ActionView < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            # We have to monkey patch because ruby < 2.0 does not support prepend.
            alias_method :_timber_old_render_collection, :render_collection
            alias_method :_timber_old_render_partial, :render_partial
            alias_method :_timber_old_render_template, :render_template

            def render_collection(event)
              context = Contexts::ActionViewTemplateRender.new(event)
              CurrentContext.add(context) do
                _timber_old_render_collection(event)
              end
            end

            def render_partial(event)
              context = Contexts::ActionViewTemplateRender.new(event)
              CurrentContext.add(context) do
                _timber_old_render_partial(event)
              end
            end

            def render_template(event)
              context = Contexts::ActionViewTemplateRender.new(event)
              CurrentContext.add(context) do
                _timber_old_render_template(event)
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
        return true if ::ActionView::LogSubscriber.include?(InstanceMethods)
        ::ActionView::LogSubscriber.send(:include, InstanceMethods)
      end
    end
  end
end
