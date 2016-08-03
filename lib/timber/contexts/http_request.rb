module Timber
  module Contexts
    class HTTPRequest < Context
      VERSION = "1".freeze
      KEY_NAME = "http_request".freeze

      property :connect_time_ms,
        :content_type,
        :host,
        :ip,
        :method,
        :path,
        :port,
        :query_params,
        :referrer,
        :request_id,
        :scheme,
        :user_agent
    end
  end
end
