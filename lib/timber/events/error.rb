require "timber/event"
require "timber/util"

module Timber
  module Events
    # The error event is used to track errors and exceptions.
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActionDispatch::DebugExceptions} integration.
    class Error < Timber::Event
      BACKTRACE_JSON_MAX_BYTES = 8192.freeze
      MESSAGE_MAX_BYTES = 8192.freeze

      attr_reader :name, :error_message, :backtrace

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @name = normalizer.fetch!(:name, :string)
        @error_message = normalizer.fetch(:error_message, :string, :limit => MESSAGE_MAX_BYTES)
        @backtrace = normalizer.fetch(:backtrace, :array)
      end

      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:name, name)
          h.add(:message, error_message)
          h.add(:backtrace_json, backtrace, :json_encode => true, :limit => BACKTRACE_JSON_MAX_BYTES)
        end
      end
      alias to_h to_hash

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {:error => to_hash}
      end

      def message
        message = "#{name}"

        if !error_message.nil?
          message << " (#{error_message})"
        end

        message
      end
    end
  end
end