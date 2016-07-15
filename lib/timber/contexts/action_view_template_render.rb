module Timber
  module Contexts
    class ActionViewTemplateRender < Context
      VERSION = "1".freeze
      KEY_NAME = "ruby_action_view_template_render".freeze

      attr_reader :event
      property :cache_hits, :count, :identifier, :layout, :time_ms

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

      def identifier
        @identifier ||= payload[:identifier]
      end

      def layout
        @layout ||= payload[:layout]
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
