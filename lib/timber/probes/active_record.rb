module Timber
  module Probes
    class ActiveRecord < Probe
      module InstanceMethods
        def self.included(klass)
          klass.class_eval do
            alias_method :old_sql, :sql

            def sql(event)
              # AR only logs queries if debugging, no need to do anything otherwise
              return unless logger.debug?
              context = Contexts::ActiveRecordQuery.new(event)
              CurrentContext.add(context) do
                old_sql(event)
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
        ::ActiveRecord::LogSubscriber.send(:include, InstanceMethods)
      end
    end
  end
end
