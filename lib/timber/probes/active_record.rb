module Timber
  module Probes
    class ActiveRecord < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            # We have to monkey patch because ruby < 2.0 does not support prepend.
            alias_method :_timber_old_sql, :sql

            def sql(event)
              # AR only logs queries if debugging, no need to do anything otherwise
              return unless logger.debug?
              context = Contexts::ActiveRecordQuery.new(self, event)
              CurrentContext.add(context) do
                _timber_old_sql(event)
              end
            end
          end
        end
      end

      def initialize
        require "active_record/log_subscriber"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if ::ActiveRecord::LogSubscriber.include?(InstanceMethods)
        ::ActiveRecord::LogSubscriber.send(:include, InstanceMethods)
      end
    end
  end
end
