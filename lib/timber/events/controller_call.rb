require "timber/event"
require "timber/util"

module Timber
  module Events
    # The controller call event tracks controller invocations. For example, this line in Rails:
    #
    #   Processing by PagesController#home as HTML
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActionController} integration.
    class ControllerCall < Timber::Event
      ACTION_MAX_BYTES = 256.freeze
      FORMAT_MAX_BYTES = 256.freeze
      CONTROLLER_MAX_BYTES = 256.freeze
      PARAMS_JSON_MAX_BYTES = 32_768.freeze
      PASSWORD_NAME = 'password'.freeze

      attr_reader :controller, :action, :params, :format

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @controller = normalizer.fetch!(:controller, :string, :limit => CONTROLLER_MAX_BYTES)
        @action = normalizer.fetch!(:action, :string, :limit => ACTION_MAX_BYTES)
        @params = normalizer.fetch(:params, :hash, :sanitize => [PASSWORD_NAME])
        @format = normalizer.fetch(:format, :string, :limit => FORMAT_MAX_BYTES)
      end

      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:controller, controller)
          h.add(:action, action)
          h.add(:params_json, params.to_json.byteslice(0, PARAMS_JSON_MAX_BYTES))
        end
      end
      alias to_h to_hash

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {:controller_call => to_hash}
      end

      def message
        message = "Processing by #{controller}##{action}"
        if !message.nil?
          message << " as #{format}"
        end
        if !params.nil? && params.length > 0
          message << "\n  Parameters: #{params.inspect}"
        end
        message
      end
    end
  end
end