require "timber/probes/active_support_log_subscriber/action_controller"
require "timber/probes/active_support_log_subscriber/action_view"
require "timber/probes/active_support_log_subscriber/active_record"

module Timber
  module Probes
    # We want to wrap every log subscriber. Think about something like
    # lograge. We want to add context to those logs as well, not just
    # the internal rails log subscribers.
    class ActiveSupportLogSubscriber < Probe
      module ClassMethods
        def self.included(klass)
          klass.class_eval do
            alias_method :_timber_old_send, :send

            # Override send since the #finish method uses that to send the event.
            # This allows us to wrap the actual method.
            def send(method_name, *args, &block)
              if args.first.is_a?(ActiveSupport::Notifications::Event)
                ActiveSupportLogSubscriber.wrap(self, args.first) do
                  _timber_old_send(method_name, *args, &block)
                end
              else
                _timber_old_send(method_name, *args, &block)
              end
            end
          end
        end
      end

      class << self
        WRAPPER_MAP = {
          "action_controller" => ActionController,
          "action_view"       => ActionView,
          "active_record"     => ActiveRecord
        }.freeze
        EVENT_DELIMITER = ".".freeze

        def wrap(log_subscriber, event, &_block)
          event_name, namespace = event.name.split(EVENT_DELIMITER)
          wrapper = WRAPPER_MAP[namespace]
          if wrapper && wrapper.respond_to?(event_name)
            wrapper.send(event_name, log_subscriber, event) { yield }
          else
            yield
          end
        end
      end

      def initialize
        require "active_support/log_subscriber"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if ::ActiveSupport::LogSubscriber.include?(ClassMethods)
        ::ActiveSupport::LogSubscriber.send(:include, ClassMethods)
      end
    end
  end
end
