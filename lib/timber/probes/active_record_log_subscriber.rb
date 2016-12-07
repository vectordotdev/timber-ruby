module Timber
  module Probes
    class ActiveRecordLogSubscriber < Probe #:nodoc:
      def initialize
        require "active_record/log_subscriber"
        require "timber/probes/active_record_log_subscriber/log_subscriber"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if Util::ActiveSupportLogSubscriber.subscribed?(:active_record, LogSubscriber)
        Util::ActiveSupportLogSubscriber.unsubscribe(:active_record, ::ActiveRecord::LogSubscriber)
        LogSubscriber.attach_to(:active_record)
      end
    end
  end
end