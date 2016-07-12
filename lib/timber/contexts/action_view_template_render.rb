module Timber
  module Contexts
    class ActionViewTemplateRender < Context
      VERSION = "1".freeze
      KEY_NAME = "ruby-action_view-template_render".freeze

      property :identifier, :layout, :time_ms

      def initialize(event)
        payload = event.payload
        @connection_id = payload[:connection_id]
        @transaction_id = payload[:transaction_id]
        @time_ms = event.duration
        super()
      end
    end
  end
end
