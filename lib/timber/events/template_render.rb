module Timber
  module Events
    # The template render event track template renderings and their performance.
    #
    # @note This event should be installed automatically through probes,
    #   such as the {Probes::ActionViewLogSubscriber} probe.
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
        {:server_side_app => {:template_render => to_hash}}
      end
    end
  end
end