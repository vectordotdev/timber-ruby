module Timber
  module Contexts
    # Generica HTTP response shared across all platforms.
    class HTTPResponse < Context
      VERSION = "1".freeze
      KEY_NAME = "http_response".freeze

      property :headers,
        :location,
        :status,
        :time_ms
    end
  end
end
