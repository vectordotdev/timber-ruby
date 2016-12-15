module Timber
  module Contexts
    # The HTTP content tracks the current HTTP request being processed. This serves
    # as join data across your logs, allowing you to query all logs for any attribute
    # presented here. For example, viewing all logs for a given request_id.
    #
    # @note This context should be installed automatically through probes,
    #   such as the {Probes::RackHTTPContext} probe.
    class HTTP < Context
      @keyspace = :http

      attr_reader :method, :path, :remote_addr, :request_id

      def initialize(attributes)
        @method = attributes[:method] || raise(ArgumentError.new(":method is required"))
        @path = attributes[:path] || raise(ArgumentError.new(":path is required"))
        @remote_addr = attributes[:remote_addr]
        @request_id = attributes[:request_id]
      end

      def as_json(_options = {})
        {:method => method, :path => path, :remote_addr => remote_addr, :request_id => request_id}
      end
    end
  end
end