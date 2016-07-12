module Timber
  module Contexts
    class ActionViewTemplateRender < Context
      VERSION = "1".freeze
      KEY_NAME = "ruby_action_view_template_render".freeze

      property :cache_hits, :count, :identifier, :layout, :time_ms

      def initialize(event)
        payload = event.payload
        @cache_hits = payload[:cache_hits]
        @count = payload[:count]
        @identifier = payload[:identifier]
        @layout = payload[:layout]
        @time_ms = event.duration
        super()
      end
    end
  end
end
