module Timber
  module Probes
    class ActiveRecordLogSubscriber < Probe # :nodoc:
      class LogSubscriber < ::ActiveRecord::LogSubscriber # :nodoc:
        def sql(event)
          return unless logger.debug?

          self.class.runtime += event.duration

          payload = event.payload

          return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

          name  = "#{payload[:name]} (#{event.duration.round(1)}ms)"
          sql   = payload[:sql]
          binds = nil

          unless (payload[:binds] || []).empty?
            binds = "  " + payload[:binds].map { |attr| render_bind(attr) }.inspect
          end

          name = colorize_payload_name(name, payload[:name])
          sql  = color(sql, sql_color(sql), true)

          message = "  #{name}  #{sql}#{binds}"

          event = Events::SQLQuery.new(
            sql: payload[:sql],
            time_ms: event.duration,
            message: message
          )

          debug event
        end
      end
    end
  end
end