require "timber/integrations/rack/middleware"

module Timber
  module Integrations
    module Rack
      # Reponsible for capturing and logging HTTP server requests and response events.
      class HTTPEvents < Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          start = Time.now
          request = Util::Request.new(env)

          Config.instance.logger.info do
            Events::HTTPServerRequest.new(
              headers: request.headers,
              host: request.host,
              method: request.request_method,
              path: request.path,
              port: request.port,
              query_string: request.query_string,
              request_id: request.request_id, # we insert this middleware after ActionDispatch::RequestId
              scheme: request.scheme
            )
          end

          status, headers, body = @app.call(env)

          Config.instance.logger.info do
            time_ms = (Time.now - start) * 1000.0
            Events::HTTPServerResponse.new(
              headers: headers,
              request_id: request.request_id,
              status: status,
              time_ms: time_ms
            )
          end

          [status, headers, body]
        end
      end
    end
  end
end