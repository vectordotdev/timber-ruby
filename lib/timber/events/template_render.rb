module Timber
  module Events
    class TemplateRender < Timber::Event
      attr_reader :message, :name, :time_ms

      def initialize(attributes)
        @message = attributes[:message] || raise(ArgumentError.new(":message is required"))
        @name = attributes[:name] || raise(ArgumentError.new(":name is required"))
        @time_ms = attributes[:time_ms] || raise(ArgumentError.new(":time_ms is required"))
      end

      def to_hash
        {name: name, time_ms: time_ms}
      end
      alias to_h to_hash

      def as_json(_options = {})
        {:template_render => to_hash}
      end
    end
  end
end