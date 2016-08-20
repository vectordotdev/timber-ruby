module Timber
  module Contexts
    class TemplateRender < Context
      ROOT_KEY = :template_render.freeze
      VERSION = 1.freeze

      private
        def json_payload
          @json_payload ||= Core::DeepMerger.merge(super, {
            _root_key => {
              :name => name,
              :time_ms => time_ms
            }
          })
        end
    end
  end
end
