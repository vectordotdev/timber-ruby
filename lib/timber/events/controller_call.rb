module Timber
  module Events
    # The controller call event tracks controller invocations. For example, this line in Rails:
    #
    #   Processing by PagesController#home as HTML
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActionController::LogSubscriber} integration.
    class ControllerCall < Timber::Event
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

      def as_json(_options = {})
        {:server_side_app => {:controller_call => to_hash}}
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
            params.each_with_object({}) do |(k, v), h|
              k = k.to_s.downcase
              case k
              when PASSWORD_NAME
                h[k] = SANITIZED_VALUE
              else
                h[k] = value
              end
            end
          else
            params
          end
        end
    end
  end
end