module Timber
  module Probes
    class ActionDispatchDebugExceptions < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            private
              # We have to monkey patch because ruby < 2.0 does not support prepend.
              alias_method :_timber_old_log_error, :log_error

              def log_error(*args)
                # Rails 3.0 has 1 arg, >= 3.1 uses 2 args, the last being an exception wrapper
                exception = args.size == 1 ? args.first : args.last.exception
                # AR only logs queries if debugging, no need to do anything otherwise
                context = Contexts::Exception.new(exception)
                CurrentContext.add(context) do
                  _timber_old_log_error(*args)
                end
              end
          end
        end
      end

      attr_reader :target_class

      def initialize
        load_debug_exceptions
      rescue RequirementNotMetError
        load_show_exceptions
      end

      def insert!
        return true if target_class.include?(InstanceMethods)
        target_class.send(:include, InstanceMethods)
      end

      private
        # Rails >= 3.1 logs the error here
        def load_debug_exceptions
          require "action_dispatch/middleware/debug_exceptions"
          @target_class = ::ActionDispatch::DebugExceptions
          true
        rescue LoadError => e
          raise RequirementNotMetError.new(e.message)
        end

        # Rails 3.0 logs the error here
        def load_show_exceptions
          require "action_dispatch/middleware/show_exceptions"
          @target_class = ::ActionDispatch::ShowExceptions
          true
        rescue LoadError => e
          raise RequirementNotMetError.new(e.message)
        end
    end
  end
end
