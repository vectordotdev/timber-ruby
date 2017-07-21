require "timber/event"
require "timber/util"

module Timber
  module Events
    # The HTTP server response event tracks outgoing HTTP responses that you send
    # to clients.
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActionController::LogSubscriber} integration.
    class HTTPResponse < Timber::Event
      attr_reader :body, :headers, :http_context, :request_id, :service_name, :status, :time_ms

      def initialize(attributes)
        @body = attributes[:body] && Util::HTTPEvent.normalize_body(attributes[:body])
        @headers = Util::HTTPEvent.normalize_headers(attributes[:headers])
        @http_context = attributes[:http_context]
        @request_id = attributes[:request_id]
        @status = attributes[:status] || raise(ArgumentError.new(":status is required"))
        @time_ms = attributes[:time_ms] || raise(ArgumentError.new(":time_ms is required"))
        @time_ms = @time_ms.round(6)
      end

      def to_hash
        {body: body, headers: headers, request_id: request_id, status: status, time_ms: time_ms}
      end
      alias to_h to_hash

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {:http_response => to_hash}
      end

      # Returns the human readable log message for this event.
      def message
        if http_context
          "#{http_context[:method]} #{http_context[:path]} sent #{status} #{status_description} " \
            "in #{time_ms}ms"
        else
          "Completed #{status} #{status_description} in #{time_ms}ms"
        end
      end

      def status_description
        Rack::Utils::HTTP_STATUS_CODES[status]
      end
    end
  end
end