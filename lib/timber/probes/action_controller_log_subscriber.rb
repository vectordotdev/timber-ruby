module Timber
  module Probes
    class ActionControllerLogSubscriber < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            # We have to monkey patch because ruby < 2.0 does not support prepend.
            alias_method :_timber_old_process_action, :process_action

            def process_action(event)
              context = Contexts::ActionControllerResponse.new(event)
              CurrentContext.add(context) do
                _timber_old_process_action(event)
              end
            end

            def send_file(event)
              context = Contexts::ActionControllerResponse.new(event)
              CurrentContext.add(context) do
                _timber_old_process_access(event)
              end
            end

            def redirect_to(event)
              context = Contexts::ActionControllerResponse.new(event)
              CurrentContext.add(context) do
                _timber_old_process_access(event)
              end
            end

            def send_data(event)
              context = Contexts::ActionControllerResponse.new(event)
              CurrentContext.add(context) do
                _timber_old_process_access(event)
              end
            end
          end
        end
      end

      def initialize
        require "action_controller/log_subscriber"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if ::ActionController::LogSubscriber.include?(InstanceMethods)
        ::ActionController::LogSubscriber.send(:include, InstanceMethods)
      end
    end
  end
end
