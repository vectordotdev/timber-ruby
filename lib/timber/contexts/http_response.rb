module Timber
  module Contexts
    # Generica HTTP response shared across all platforms.
    class HTTPResponse < Context
      ROOT_KEY = :http_response.freeze
      VERSION = 1.freeze

      private
        def json_payload
          @json_payload ||= Core::DeepMerger.merge({
            _root_key => {
              # order is relevant for logfmt styling
              :status => status,
              :headers => headers,
              :time_ms => time_ms
            }
          }, super)
        end
    end
  end
end
