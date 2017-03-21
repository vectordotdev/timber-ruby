module Timber
  module Util
    module HTTPEvent
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

        if body.is_a?(::String) && body.length > 10_000
          body.truncate(10_000)
        else
          body
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

        if query_string.length > 10_000
          query_string.truncate(10_000)
        else
          query_string
        end
      end
    end
  end
end