module Timber
  module Contexts
    class TemplateRender < Context
      ROOT_KEY = :template_render.freeze
      VERSION = 1.freeze

      private
        def json_payload
          @json_payload ||= Macros::DeepMerger.merge({
            _root_key => {
              # order is relevant for logfmt styling
              :name => name,
              :time_ms => time_ms
            }
          }, super)
        end
    end
  end
end
