require "timber/context"

module Timber
  module Contexts
    # The HTTP context adds data about the current HTTP request being processed to your logs.
    # This allows you to tail and filter by this data. A very useful piece of data this
    # captures is the request ID. This gives you the ability to trace requests and view logs
    # for a specific request only. For example, say you've searched your logs and found the
    # specific line you are looking for, but it lacks context. With Timber you can simply
    # click the request ID and "zoom out" to view all logs for that request. This gives you
    # complete picture of how the log line in questio was generated.
    #
    # @note This context should be installed automatically through the,
    #   {Intregrations::Rack::HTTPContext} Rack middleware.
    class HTTP < Context
      @keyspace = :http

      attr_reader :host, :method, :path, :remote_addr, :request_id

      def initialize(attributes)
        @host = attributes[:host]
        @method = attributes[:method] || raise(ArgumentError.new(":method is required"))
        @path = attributes[:path]
        @remote_addr = attributes[:remote_addr]
        @request_id = attributes[:request_id]
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {:host => host, :method => method, :path => path, :remote_addr => remote_addr,
          :request_id => request_id}
      end
    end
  end
end