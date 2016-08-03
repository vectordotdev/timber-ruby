module Timber
  module Contexts
    # Generica HTTP response shared across all platforms.
    class HTTPResponse < Context
      VERSION = "1".freeze
      KEY_NAME = "http_response".freeze

      property :content_length,
        :cache_control,
        :content_disposition,
        :content_type,
        :location,
        :status,
        :time_ms
    end
  end
end
