module Timber
  module Events
    # The controller call event tracks controller invocations. For example, this line in Rails:
    #
    #   Processing by PagesController#home as HTML
    #
    # @note This event should be installed automatically through probes,
    #   such as the {Probes::ActionControllerLogSubscriber} probe.
    class ControllerCall < Timber::Event
      attr_reader :controller, :action, :params, :format

      def initialize(attributes)
        @controller = attributes[:controller] || raise(ArgumentError.new(":controller is required"))
        @action = attributes[:action] || raise(ArgumentError.new(":action is required"))
        @params = attributes[:params]
        @format = attributes[:format]
      end

      def to_hash
        {controller: controller, action: action}
      end
      alias to_h to_hash

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