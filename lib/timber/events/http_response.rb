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
      BODY_MAX_BYTES = 8192.freeze
      HEADERS_JSON_MAX_BYTES = 256.freeze
      HEADERS_TO_SANITIZE = ['authorization', 'x-amz-security-token'].freeze
      REQUEST_ID_MAX_BYTES = 256.freeze
      SERVICE_NAME_MAX_BYTES = 256.freeze

      attr_reader :body, :content_length, :headers, :http_context, :request_id, :service_name,
        :status, :time_ms

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        body_limit = Config.instance.http_body_limit || BODY_MAX_BYTES
        headers_to_sanitize = HEADERS_TO_SANITIZE + (Config.instance.http_header_filters || [])

        @body = normalizer.fetch(:body, :string, :limit => body_limit)
        @content_length = normalizer.fetch(:content_length, :integer)
        @headers = normalizer.fetch(:headers, :hash, :sanitize => headers_to_sanitize)
        @http_context = attributes[:http_context]
        @request_id = normalizer.fetch(:request_id, :string, :limit => REQUEST_ID_MAX_BYTES)
        @service_name = normalizer.fetch(:service_name, :string, :limit => SERVICE_NAME_MAX_BYTES)
        @status = normalizer.fetch!(:status, :integer)
        @time_ms = normalizer.fetch!(:time_ms, :float, :precision => 6)
      end

      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:body, body)
          h.add(:content_length, content_length)
          h.add(:headers_json, headers, :json_encode => true, :limit => HEADERS_JSON_MAX_BYTES)
          h.add(:request_id, request_id)
          h.add(:service_name, service_name)
          h.add(:status, status)
          h.add(:time_ms, time_ms)
        end
      end
      alias to_h to_hash

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {:http_response => to_hash}
      end

      # Returns the human readable log message for this event.
      def message
        if http_context
          message = "#{http_context[:method]} #{http_context[:path]} completed with " \
            "#{status} #{status_description} "

          if content_length
            message << ", #{content_length} bytes, "
          end

          message << "in #{time_ms}ms"
        else
          message = "Completed #{status} #{status_description} "

          if content_length
            message << ", #{content_length} bytes, "
          end

          message << "in #{time_ms}ms"
        end
      end

      def status_description
        Rack::Utils::HTTP_STATUS_CODES[status]
      end
    end
  end
end