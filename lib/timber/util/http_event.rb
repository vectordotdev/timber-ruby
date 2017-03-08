module Timber
  module Util
    module HTTPEvent
      def self.full_path(path, query_string)
        if query_string
          "#{path}?#{query_string}"
        else
          path
        end
      end

      def self.normalize_body(body)
        if body.is_a?(String) && body.length > 2000
          body.truncate(2000)
        else
          body
        end
      end

      def normalize_headers(headers)

      end
    end
  end
end