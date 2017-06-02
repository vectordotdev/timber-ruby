require "timber/event"
require "timber/util"

module Timber
  module Events
    # The controller call event tracks controller invocations. For example, this line in Rails:
    #
    #   Processing by PagesController#home as HTML
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActionController::LogSubscriber} integration.
    class ControllerCall < Timber::Event
      PASSWORD_NAME = 'password'.freeze

      attr_reader :controller, :action, :params, :format

      def initialize(attributes)
        @controller = attributes[:controller] || raise(ArgumentError.new(":controller is required"))
        @action = attributes[:action] || raise(ArgumentError.new(":action is required"))
        @params = sanitize_params(attributes[:params])
        @format = attributes[:format]
      end

      def to_hash
        {controller: controller, action: action, params_json: params_json}
      end
      alias to_h to_hash

      # Builds a hash representation of containing simply objects, suitable for serialization.
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

      private
        def params_json
          @params_json ||= if params.nil? || params == {}
            nil
          else
            params.to_json
          end
        end

        def sanitize_params(params)
          if params.is_a?(::Hash)
            Util::Hash.sanitize(params, [PASSWORD_NAME])
          else
            params
          end
        end
    end
  end
end