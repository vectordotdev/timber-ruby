module Timber
  module Probes
    class ActionViewLogSubscriber < Probe
      # The log subscriber that replaces the default `ActionView::LogSubscriber`.
      # The intent of this subscriber is to, as transparently as possible, properly
      # track events that are being logged here. This LogSubscriber will never change
      # default behavior / log messages.
      class LogSubscriber < ::ActionView::LogSubscriber
        def render_template(event)
          info do
            full_name = from_rails_root(event.payload[:identifier])
            message = "  Rendered #{full_name}"
            message << " within #{from_rails_root(event.payload[:layout])}" if event.payload[:layout]
            message << " (#{event.duration.round(1)}ms)"

            Events::TemplateRender.new(
              name: full_name,
              time_ms: event.duration,
              message: message
            )
          end
        end

        def render_partial(event)
          info do
            full_name = from_rails_root(event.payload[:identifier])
            message = "  Rendered #{full_name}"
            message << " within #{from_rails_root(event.payload[:layout])}" if event.payload[:layout]
            message << " (#{event.duration.round(1)}ms)"
            message << " #{cache_message(event.payload)}" if event.payload.key?(:cache_hit)

            Events::TemplateRender.new(
              name: full_name,
              time_ms: event.duration,
              message: message
            )
          end
        end

        def render_collection(event)
          info do
            identifier = event.payload[:identifier] || "templates"
            full_name = from_rails_root(identifier)
            message = "  Rendered collection of #{full_name}" \
              " #{render_count(event.payload)} (#{event.duration.round(1)}ms)"

            Events::TemplateRender.new(
              name: full_name,
              time_ms: event.duration,
              message: message
            )
          end
        end

        private
          def log_rendering_start(payload)
            # Rails, you silly. We don't need to template rendering messages :)
          end
      end
    end
  end
end