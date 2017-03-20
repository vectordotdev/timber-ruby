module Timber
  module Events
    # The HTTP request event tracks incoming HTTP requests.
    #
    # @note This event should be installed automatically through probes,
    #   such as the {Probes::ActionControllerLogSubscriber} probe.
    class HTTPServerRequest < Timber::Event
      attr_reader :headers, :host, :method, :path, :port, :query_string, :request_id, :scheme

      def initialize(attributes)
        @headers = attributes[:headers]
        @host = attributes[:host] || raise(ArgumentError.new(":host is required"))
        @method = attributes[:method] || raise(ArgumentError.new(":method is required"))
        @path = attributes[:path] || raise(ArgumentError.new(":path is required"))
        @port = attributes[:port]
        @query_string = attributes[:query_string]
        @request_id = attributes[:request_id]
        @scheme = attributes[:scheme] || raise(ArgumentError.new(":scheme is required"))
      end

      def to_hash
        {headers: headers, host: host, method: method, path: path, port: port,
          query_string: query_string, request_id: request_id, scheme: scheme}
      end
      alias to_h to_hash

      def as_json(_options = {})
        {:server_side_app => {:http_server_request => to_hash}}
      end

      def message
        'Started %s "%s"' % [method, path]
      end
    end
  end
end