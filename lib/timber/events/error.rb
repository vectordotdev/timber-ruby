require "timber/event"
require "timber/util"

module Timber
  module Events
    # The error event is used to track errors and exceptions.
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActionDispatch::DebugExceptions} integration.
    class Error < Timber::Event
      MESSAGE_MAX_BYTES = 8192.freeze

      attr_reader :name, :error_message, :backtrace

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @name = normalizer.fetch!(:name, :string)
        @error_message = normalizer.fetch(:error_message, :string, :limit => MESSAGE_MAX_BYTES)
        @backtrace = normalizer.fetch(:backtrace, :array)

        if !backtrace.nil? && backtrace != []
          @backtrace = backtrace[0..19].collect { |line| parse_backtrace_line(line) }
        end
      end

      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:name, name)
          h.add(:message, error_message)
          h.add(:backtrace, backtrace)
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

      private
        def parse_backtrace_line(line)
          # using split for performance reasons
          file, line, function_part = line.split(":", 3)

          parsed_line = {file: file}

          if line
            parsed_line[:line] = line.to_i
          end

          if function_part
            _prefix, function_pre = function_part.split("`", 2)
            function = Util::Object.try(function_pre, :chomp, "'")
            parsed_line[:function] = function
          end

          parsed_line
        end
    end
  end
end