module Timber
  module Util
    module HTTPEvent
      BODY_LIMIT = 5_000.freeze
      QUERY_STRING_LIMIT = 5_000.freeze

      extend self

      def full_path(path, query_string)
        if query_string
          "#{path}?#{query_string}"
        else
          path
        end
      end

      def normalize_body(content_type, body)
        if Config.instance.capture_http_body_content_types.include?(content_type)
          if body.respond_to?(:body)
            body = body.body.to_s
          end

          body[0..(BODY_LIMIT - 1)]
        else
          # Drop the body if it is not a format we want to capture.
          # This gives users more control to avoid loggin files, etc.
          nil
        end
      end

      def normalize_headers(headers)
        if headers.is_a?(::Hash)
          headers.each_with_object({}) do |(k, v), h|
            h[k.to_s.downcase] = v
          end
        else
          headers
        end
      end

      def normalize_method(method)
        method.is_a?(::String) ? method.upcase : method
      end

      def normalize_query_string(query_string)
        if !query_string.nil?
          query_string = query_string.to_s
        end

        query_string[0..(QUERY_STRING_LIMIT - 1)]
      end
    end
  end
end