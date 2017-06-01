module Timber
  module Util
    # Utility module for dealing with HTTP events {Events::HTTPServerRequest},
    # {Events::HTTPServerResponse}, {Events::HTTPClientRequest}, {Events::HTTPClientResponse}.
    module HTTPEvent
      HEADERS_TO_SANITIZE = ['authorization', 'x-amz-security-token'].freeze
      QUERY_STRING_LIMIT = 5_000.freeze
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
          body[0..(limit - 1)]
        else
          body
        end
      end

      # Normalizes headers to:
      #
      # 1. Ensure the value is UTF8, this will otherwise throw errors upon capturing.
      # 2. Sanitize sensitive headers such as `Authorization` or custom headers specified in
      def normalize_headers(headers)
        if headers.is_a?(::Hash)
          h = headers.each_with_object({}) do |(k, v), h|
            # Force the header into a valid UTF-8 string, otherwise we will encounter
            # encoding issues when we serialize this data. Moreoever, if the
            # data is already valid UTF-8 we don't pay a penalty.
            #
            # Note: we compare the class name because...
            #
            #   string = 'my string'.force_encoding('ASCII-8BIT')
            #   string.is_a?(String) => false
            #   string.class => String
            #   string.class == String => false
            #   string.class.name == "String" => true
            #
            # ¯\_(ツ)_/¯
            if v.class.name == STRING_CLASS_NAME
              h[k] = Timber::Util::String.normalize_to_utf8(v)
            else
              h[k] = v
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

        query_string && query_string[0..(QUERY_STRING_LIMIT - 1)]
      end
    end
  end
end