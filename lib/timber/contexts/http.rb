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
      HOST_MAX_BYTES = 256.freeze
      METHOD_MAX_BYTES = 20.freeze
      PATH_MAX_BYTES = 2048.freeze
      REMOTE_ADDR_MAX_BYTES = 256.freeze
      REQUEST_ID_MAX_BYTES = 256.freeze

      @keyspace = :http

      attr_reader :host, :method, :path, :remote_addr, :request_id

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @host = normalizer.fetch(:host, :string, :limit => HOST_MAX_BYTES)
        @method = normalizer.fetch!(:method, :string, :upcase => true, :limit => METHOD_MAX_BYTES)
        @path = normalizer.fetch(:path, :string, :limit => PATH_MAX_BYTES)
        @remote_addr = normalizer.fetch(:remote_addr, :string, :limit => REMOTE_ADDR_MAX_BYTES)
        @request_id = normalizer.fetch(:request_id, :string, :limit => REQUEST_ID_MAX_BYTES)
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:host, host)
          h.add(:method, method)
          h.add(:path, path)
          h.add(:remote_addr, remote_addr)
          h.add(:request_id, request_id)
        end
      end
    end
  end
end
