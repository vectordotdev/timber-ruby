require "timber/event"
require "timber/util"

module Timber
  module Events
    # The HTTP client response event tracks responses for *outgoing* HTTP *requests*.
    # This gives you structured insight into communication with external services.
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::NetHTTP} integration.
    class HTTPClientResponse < Timber::Event
      attr_reader :body, :headers, :request_id, :service_name, :status, :time_ms

      def initialize(attributes)
        @headers = Util::HTTPEvent.normalize_headers(attributes[:headers])
        @request_id = attributes[:request_id]
        @service_name = attributes[:service_name]
        @status = attributes[:status] || raise(ArgumentError.new(":status is required"))
        @time_ms = attributes[:time_ms] || raise(ArgumentError.new(":time_ms is required"))
        @time_ms = @time_ms.round(6)

        @body = Util::HTTPEvent.normalize_body(@headers["content-type"], attributes[:body])
      end

      def to_hash
        {body: body, headers: headers, request_id: request_id, service_name: service_name,
          status: status, time_ms: time_ms}
      end
      alias to_h to_hash

      def as_json(_options = {})
        {:http_client_response => to_hash}
      end

      def message
        message = "Outgoing HTTP response"

        if service_name
          message << " from #{service_name}"
        end

        message << " #{status_description} in #{time_ms}ms"
      end

      def status_description
        Rack::Utils::HTTP_STATUS_CODES[status]
      end
    end
  end
end