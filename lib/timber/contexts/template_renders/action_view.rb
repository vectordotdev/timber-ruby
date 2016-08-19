module Timber
  module Contexts
    module TemplateRenders
      class ActionView < Context
        attr_reader :event

        def initialize(event)
          # Initialize should be as fast as possible since it is executed inline.
          # Hence the lazy methods below.
          @event = event
          super()
        end

        def name
          @name ||= payload[:identifier]
        end

        def time_ms
          @time_ms ||= event.duration
        end

        private
          def payload
            event.payload
          end
      end
    end
  end
end
