module Timber
  module Contexts
    class HTTPRequest < Context
      ROOT_KEY = :http_request.freeze
      VERSION = 1.freeze

      private
        def json_payload
          @json_payload ||= Core::DeepMerger.merge({
            _root_key => {
              # order is relevant for logfmt styling
              :method => method,
              :scheme => scheme,
              :host => host,
              :port => port,
              :path => path,
              :query_params => query_params.as_json,
              :headers => headers.as_json
            }
          }, super)
        end
    end
  end
end
