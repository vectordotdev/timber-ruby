module Timber
  module Util
    module ActiveSupportLogSubscriber #:nodoc:
      extend self

      def find(component, type)
        ActiveSupport::LogSubscriber.log_subscribers.find do |subscriber|
          subscriber.class == type
        end
      end

      def subscribed?(component, type)
        !find(component, type).nil?
      end

      def unsubscribe(component, type)
        subscriber = find(component, type)

        if subscriber
          events = subscriber.public_methods(false).reject { |method| method.to_s == 'call' }
          events.each do |event|
            ActiveSupport::Notifications.notifier.listeners_for("#{event}.#{component}").each do |listener|
              if listener.instance_variable_get('@delegate') == subscriber
                ActiveSupport::Notifications.unsubscribe listener
              end
            end
          end
        end
      end
    end
  end
end