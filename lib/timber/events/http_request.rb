require "timber/event"
require "timber/util"

module Timber
  module Events
    # The HTTP server request event tracks incoming HTTP requests to your HTTP server.
    # Such as unicorn, webrick, puma, etc.
    #
    # @note This event should be installed automatically through integrations,
    #   such as the {Integrations::ActionController::LogSubscriber} integration.
    class HTTPRequest < Timber::Event
      BODY_MAX_BYTES = 8192.freeze
      HEADERS_JSON_MAX_BYTES = 8192.freeze
      HEADERS_TO_SANITIZE = ['authorization', 'x-amz-security-token'].freeze
      HOST_MAX_BYTES = 256.freeze
      METHOD_MAX_BYTES = 20.freeze
      PATH_MAX_BYTES = 2048.freeze
      QUERY_STRING_MAX_BYTES = 2048.freeze
      REQUEST_ID_MAX_BYTES = 256.freeze
      SCHEME_MAX_BYTES = 20.freeze
      SERVICE_NAME_MAX_BYTES = 256.freeze

      attr_reader :body, :content_length, :headers, :host, :method, :path, :port, :query_string,
        :request_id, :scheme, :service_name

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        body_limit = Config.instance.http_body_limit || BODY_MAX_BYTES
        headers_to_sanitize = HEADERS_TO_SANITIZE + (Config.instance.http_header_filters || [])

        @body = normalizer.fetch(:body, :string, :limit => body_limit)
        @content_length = normalizer.fetch(:content_length, :integer)
        @headers = normalizer.fetch(:headers, :hash, :sanitize => headers_to_sanitize)
        @host = normalizer.fetch(:host, :string, :limit => HOST_MAX_BYTES)
        @method = normalizer.fetch!(:method, :string, :upcase => true, :limit => METHOD_MAX_BYTES)
        @path = normalizer.fetch(:path, :string, :limit => PATH_MAX_BYTES)
        @port = normalizer.fetch(:port, :integer)
        @query_string = normalizer.fetch(:query_string, :string, :limit => QUERY_STRING_MAX_BYTES)
        @scheme = normalizer.fetch(:scheme, :string, :limit => SCHEME_MAX_BYTES)
        @request_id = normalizer.fetch(:request_id, :string, :limit => REQUEST_ID_MAX_BYTES)
        @service_name = normalizer.fetch(:service_name, :string, :limit => SERVICE_NAME_MAX_BYTES)
      end

      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:body, body)
          h.add(:content_length, content_length)
          h.add(:headers_json, headers, :json_encode => true, :limit => HEADERS_JSON_MAX_BYTES)
          h.add(:host, host)
          h.add(:method, method)
          h.add(:path, path)
          h.add(:port, port)
          h.add(:query_string, query_string)
          h.add(:request_id, request_id)
          h.add(:scheme, scheme)
          h.add(:service_name, service_name)
        end
      end
      alias to_h to_hash

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {:http_request => to_hash}
      end

      def message
        'Started %s "%s"' % [method, path]
      end
    end
  end
end