module Timber
  module Probes
    class ActionControllerLogSubscriber < Probe # :nodoc:
      class LogSubscriber < ::ActionController::LogSubscriber # :nodoc:
        def start_processing(event)
          info do
            payload = event.payload
            params  = payload[:params].except(*INTERNAL_PARAMS)
            format  = extract_format(payload)
            format  = format.to_s.upcase if format.is_a?(Symbol)

            Events::ControllerCall.new(
              controller: payload[:controller],
              action: payload[:action],
              format: format,
              params: params
            )
          end
        end

        def process_action(event)
          info do
            payload   = event.payload
            additions = ActionController::Base.log_process_action(payload)

            status = payload[:status]
            if status.nil? && payload[:exception].present?
              exception_class_name = payload[:exception].first
              status = ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
            end

            Events::HTTPResponse.new(
              status: status,
              time_ms: event.duration,
              additions: additions
            )
          end
        end

        private
          def extract_format(payload)
            if payload.key?(:format)
              payload[:format] # rails > 4.X
            elsif payload.key?(:formats)
              payload[:formats].first # rails 3.X
            end
          end
      end
    end
  end
end