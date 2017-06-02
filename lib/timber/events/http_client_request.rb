require "timber/event"
require "timber/util"

module Timber
  module Events
    # The HTTP client request event tracks *outgoing* HTTP requests giving you structured insight
    # into communication with external services.
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::NetHTTP} integration.
    class HTTPClientRequest < Timber::Event
      attr_reader :body, :headers, :host, :method, :path, :port, :query_string, :request_id,
        :scheme, :service_name

      def initialize(attributes)
        @headers = Util::HTTPEvent.normalize_headers(attributes[:headers])
        @host = attributes[:host] || raise(ArgumentError.new(":host is required"))
        @method = Util::HTTPEvent.normalize_method(attributes[:method]) || raise(ArgumentError.new(":method is required"))
        @path = attributes[:path]
        @port = attributes[:port]
        @query_string = Util::HTTPEvent.normalize_query_string(attributes[:query_string])
        @request_id = attributes[:request_id]
        @scheme = attributes[:scheme] || raise(ArgumentError.new(":scheme is required"))
        @service_name = attributes[:service_name]

        @body = Util::HTTPEvent.normalize_body(@headers["content-type"], attributes[:body])
      end

      def to_hash
        {headers: headers, host: host, method: method, parsed_body_json: parsed_body_json,
          path: path, port: port, query_string: query_string, request_id: request_id,
          scheme: scheme, service_name: service_name}
      end
      alias to_h to_hash

      # Builds a hash representation of containing simply objects, suitable for serialization.
      def as_json(_options = {})
        {:http_client_request => to_hash}
      end

      def message
        message = 'Outgoing HTTP request to '

        if service_name
          mesage << " #{service_name} [#{method}] #{full_path}"
        else
          message << " [#{method}] #{full_url}"
        end
      end

      def status_description
        Rack::Utils::HTTP_STATUS_CODES[status]
      end

      private
        def full_path
          Util::HTTPEvent.full_path(path, query_string)
        end

        def full_url
          "#{scheme}#{host}#{full_path}"
        end
    end
  end
end