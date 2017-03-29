module Timber
  module Util
    module HTTPEvent
      AUTHORIZATION_HEADER = 'authorization'.freeze
      QUERY_STRING_LIMIT = 5_000.freeze
      SANITIZED_VALUE = '[sanitized]'.freeze

      extend self

      def full_path(path, query_string)
        if query_string
          "#{path}?#{query_string}"
        else
          path
        end
      end

      def normalize_body(body)
        if body.respond_to?(:body)
          body = body.body.to_s
        end

        body[0..(Config.instance.http_body_limit - 1)]
      end

      def normalize_headers(headers)
        if headers.is_a?(::Hash)
          headers.each_with_object({}) do |(k, v), h|
            k = k.to_s.downcase
            case k
            when AUTHORIZATION_HEADER
              h[k] = SANITIZED_VALUE
            else
              if Config.instance.header_filters && Config.instance.header_filters.include?(k)
                h[k] = SANITIZED_VALUE
              else
                h[k] = v
              end
            end
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

        query_string && query_string[0..(QUERY_STRING_LIMIT - 1)]
      end
    end
  end
end