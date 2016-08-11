module Timber
  module Contexts
    class HTTPRequest < Context
      VERSION = "1".freeze
      KEY_NAME = "http_request".freeze

      property :headers,
        :host,
        :method,
        :path,
        :port,
        :query_params,
        :scheme
    end
  end
end
