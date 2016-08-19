module Timber
  module Contexts
    module TemplateRenders
      # Because this is a sub type we extend Context
      class ActionViewSpecific < TemplateRender
        attr_reader :event

        def initialize(event)
          # Initialize should be as fast as possible since it is executed inline.
          # Hence the lazy methods below.
          @event = event
          super()
        end

        def cache_hits
          @cache_hits ||= payload[:cache_hits]
        end

        def count
          @count ||= payload[:count]
        end

        def layout
          @layout ||= payload[:layout]
        end

        private
          def json_payload
            @json_payload ||= DeepMerger.merge(super, {
              TemplateRender._root_key => {
                _root_key => {
                  :cache_hits => cache_hits,
                  :count => count,
                  :layout => layout
                }
              }
            })
          end

          def payload
            event.payload
          end
      end
    end
  end
end
