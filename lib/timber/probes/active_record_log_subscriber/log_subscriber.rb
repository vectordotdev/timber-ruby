module Timber
  module Probes
    class ActiveRecordLogSubscriber < Probe #:nodoc:
      class LogSubscriber < ::ActiveRecord::LogSubscriber #:nodoc:
        def sql(event)
          return unless logger.debug?

          self.class.runtime += event.duration

          payload = event.payload

          return if defined?(IGNORE_PAYLOAD_NAMES) && IGNORE_PAYLOAD_NAMES.include?(payload[:name])

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

        private
          def colorize_payload_name(name, payload_name)
            if payload_name.blank? || payload_name == "SQL" # SQL vs Model Load/Exists
              color(name, MAGENTA, true)
            else
              color(name, CYAN, true)
            end
          end

          def sql_color(sql)
            case sql
            when /\A\s*rollback/mi
              RED
            when /select .*for update/mi, /\A\s*lock/mi
              WHITE
            when /\A\s*select/i
              BLUE
            when /\A\s*insert/i
              GREEN
            when /\A\s*update/i
              YELLOW
            when /\A\s*delete/i
              RED
            when /transaction\s*\Z/i
              CYAN
              else
              MAGENTA
            end
          end
      end
    end
  end
end