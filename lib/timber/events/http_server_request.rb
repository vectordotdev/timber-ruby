module Timber
  module Events
    # The HTTP request event tracks incoming HTTP requests.
    #
    # @note This event should be installed automatically through probes,
    #   such as the {Probes::ActionControllerLogSubscriber} probe.
    class HTTPRequest < Timber::Event
      attr_reader :host, :method, :path, :port, :query_params, :content_type,
        :remote_addr, :referrer, :request_id, :user_agent

      def initialize(attributes)
        @host = attributes[:host] || raise(ArgumentError.new(":host is required"))
        @method = attributes[:method] || raise(ArgumentError.new(":method is required"))
        @path = attributes[:path] || raise(ArgumentError.new(":path is required"))
        @port = attributes[:port]
        @query_params = attributes[:query_params]
        @content_type = attributes[:content_type]
        @remote_addr = attributes[:remote_addr]
        @referrer = attributes[:referrer]
        @request_id = attributes[:request_id]
        @user_agent = attributes[:user_agent]
      end

      def to_hash
        {host: host, method: method, path: path, port: port, query_params: query_params,
          headers: {content_type: content_type, remote_addr: remote_addr, referrer: referrer,
            request_id: request_id, user_agent: user_agent}}
      end
      alias to_h to_hash

      def as_json(_options = {})
        hash = to_hash
        hash[:headers] = Util::Hash.compact(hash[:headers])
        hash = Util::Hash.compact(hash)
        {:server_side_app => {:http_request => hash}}
      end

      def message
        'Started %s "%s" for %s' % [
        method,
        path,
        remote_addr]
      end

      def status_description
        Rack::Utils::HTTP_STATUS_CODES[status]
      end
    end
  end
end