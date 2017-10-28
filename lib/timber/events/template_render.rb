require "timber/event"

module Timber
  module Events
    # The template render event track template renderings and their performance.
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActionView::LogSubscriber} integration.
    class TemplateRender < Timber::Event
      MESSAGE_MAX_BYTES = 8192.freeze
      NAME_MAX_BYTES = 1024.freeze

      attr_reader :message, :name, :time_ms

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @message = normalizer.fetch!(:message, :string, :limit => MESSAGE_MAX_BYTES)
        @name = normalizer.fetch!(:name, :string, :limit => NAME_MAX_BYTES)
        @time_ms = normalizer.fetch!(:time_ms, :float, :precision => 6)
      end

      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:name, name)
          h.add(:time_ms, time_ms)
        end
      end
      alias to_h to_hash

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {:template_render => to_hash}
      end
    end
  end
end