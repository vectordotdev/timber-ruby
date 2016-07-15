module Timber
  module Probes
    class ActionDispatchDebugExceptions < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            alias_method :old_log_error, :log_error

            def log_error(request, wrapper)
              # AR only logs queries if debugging, no need to do anything otherwise
              context = Contexts::Exception.new(wrapper.exception)
              CurrentContext.add(context) do
                old_log_error(request, wrapper)
              end
            end
          end
        end
      end

      def initialize
        require "action_dispatch/middleware/debug_exceptions"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        ::ActionDispatch::DebugExceptions.send(:include, InstanceMethods)
      end
    end
  end
end
