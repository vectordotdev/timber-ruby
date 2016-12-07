module Timber
  module Contexts
    # Represents the HTTP content.
    class HTTP < Context
      attr_reader :method, :path, :remote_addr, :request_id

      def initialize(attributes)
        @method = attributes[:method] || raise(ArgumentError.new(":method is required"))
        @path = attributes[:path] || raise(ArgumentError.new(":path is required"))
        @remote_addr = attributes[:remote_addr]
        @request_id = attributes[:request_id]
      end

      def keyspace
        :http
      end

      def as_json(_options = {})
        {:method => method, :path => path, :remote_addr => remote_addr, :request_id => request_id}
      end
    end
  end
end