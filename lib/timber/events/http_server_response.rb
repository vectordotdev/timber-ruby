module Timber
  module Events
    # The HTTP response event tracks outgoing HTTP request responses.
    #
    # @note This event should be installed automatically through probes,
    #   such as the {Probes::ActionControllerLogSubscriber} probe.
    class HTTPResponse < Timber::Event
      attr_reader :status, :time_ms, :additions

      def initialize(attributes)
        @status = attributes[:status] || raise(ArgumentError.new(":status is required"))
        @time_ms = attributes[:time_ms] || raise(ArgumentError.new(":time_ms is required"))
        @additions = attributes[:additions]
      end

      def to_hash
        {status: status, time_ms: time_ms}
      end
      alias to_h to_hash

      def as_json(_options = {})
        {:server_side_app => {:http_response => to_hash}}
      end

      def message
        message = "Completed #{status} #{status_description} in #{time_ms}ms"
        message << " (#{additions.join(" | ".freeze)})" unless additions.empty?
        message
      end

      def status_description
        Rack::Utils::HTTP_STATUS_CODES[status]
      end
    end
  end
end