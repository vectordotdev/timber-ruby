module Timber
  module Util
    # Utility module for dealing with HTTP events {Events::HTTPServerRequest},
    # {Events::HTTPServerResponse}, {Events::HTTPClientRequest}, {Events::HTTPClientResponse}.
    module HTTPEvent
      HEADERS_TO_SANITIZE = ['authorization', 'x-amz-security-token'].freeze
      MAX_QUERY_STRING_BYTES = 2048.freeze
      STRING_CLASS_NAME = 'String'.freeze

      extend self

      def full_path(path, query_string)
        if query_string
          "#{path}?#{query_string}"
        else
          path
        end
      end

      # Normalizes the body. If limit if passed it will truncate the body to that limit.
      def normalize_body(body)
        if body.respond_to?(:body)
          body = body.body.to_s
        end

        limit = Config.instance.http_body_limit
        if limit
          body.byteslice(0, limit)
        else
          body
        end
      end

      # Normalizes headers to:
      #
      # 1. Only select values that are UTF8, otherwise they will throw errors when serializing.
      # 2. Sanitize sensitive headers such as `Authorization` or custom headers specified in
      def normalize_headers(headers)
        if headers.is_a?(::Hash)
          h = headers.each_with_object({}) do |(k, v), h|
            if v
              v = v.to_s
              if [Encoding::UTF_8, Encoding::US_ASCII].include?(v.encoding)
                h[k] = v
              end
            end
          end

          keys_to_sanitize = HEADERS_TO_SANITIZE + (Config.instance.http_header_filters || [])
          Util::Hash.sanitize(h, keys_to_sanitize)
        else
          headers
        end
      end

      # Normalizes the HTTP method into an uppercase string.
      def normalize_method(method)
        method.is_a?(::String) ? method.upcase : method
      end

      def normalize_query_string(query_string)
        if !query_string.nil?
          query_string = query_string.to_s
        end

        query_string && query_string.byteslice(0, MAX_QUERY_STRING_BYTES)
      end
    end
  end
end