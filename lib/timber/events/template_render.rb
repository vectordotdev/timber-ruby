require "timber/util"
require "timber/event"
module Timber
  module Events
    # The template render event track template renderings and their performance.
    class TemplateRender < Timber::Event
      MESSAGE_MAX_BYTES = 8192.freeze
      NAME_MAX_BYTES = 1024.freeze

      attr_reader :message, :name, :duration_ms

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @message = normalizer.fetch!(:message, :string, :limit => MESSAGE_MAX_BYTES)
        @name = normalizer.fetch!(:name, :string, :limit => NAME_MAX_BYTES)
        @duration_ms = normalizer.fetch!(:duration_ms, :float, :precision => 6)
      end

      def metadata
        hash = Util::NonNilHashBuilder.build do |h|
          h.add(:name, name)
          h.add(:duration_ms, duration_ms)
        end

        {
          event: {
            template_rendered: hash
          }
        }
      end
    end
  end
end
