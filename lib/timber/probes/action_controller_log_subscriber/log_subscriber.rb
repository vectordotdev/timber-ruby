module Timber
  module Probes
    class ActionControllerLogSubscriber < Probe # :nodoc:
      class LogSubscriber < ::ActionController::LogSubscriber # :nodoc:
        def start_processing(event)
          info do
            payload = event.payload
            params  = payload[:params].except(*INTERNAL_PARAMS)
            format  = payload[:format]
            format  = format.to_s.upcase if format.is_a?(Symbol)

            Events::ControllerCall.new(
              controller: payload[:controller],
              action: payload[:action],
              format: format,
              params: params
            )
          end
        end
      end
    end
  end
end