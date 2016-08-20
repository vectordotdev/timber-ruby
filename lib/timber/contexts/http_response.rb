module Timber
  module Contexts
    # Generica HTTP response shared across all platforms.
    class HTTPResponse < Context
      ROOT_KEY = :http_response.freeze
      VERSION = 1.freeze

      private
        def json_payload
          @json_payload ||= Core::DeepMerger.merge(super, {
            _root_key => {
              :headers => headers,
              :status => status,
              :time_ms => time_ms
            }
          })
        end
    end
  end
end
