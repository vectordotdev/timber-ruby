module Timber
  module Contexts
    class HTTPRequest < Context
      ROOT_KEY = :http_request.freeze
      VERSION = 1.freeze

      private
        def json_payload
          @json_payload ||= Core::DeepMerger.merge({
            _root_key => {
              :headers => headers,
              :host => host,
              :method => method,
              :path => path,
              :port => port,
              :query_params => query_params,
              :scheme => scheme
            }
          }, super)
        end
    end
  end
end
