module Timber
  module RackMiddlewares
    # Reponsible for capturing and logging HTTP server requests and response events.
    class HTTPEvents
      def initialize(app)
        @app = app
      end

      def call(env)
        start = Time.now

        Config.instance.logger.info do
          request = Request.new(env)
          Events::HTTPServerRequest.new(
            content_type: request.content_type,
            host: request.host,
            method: request.request_method,
            path: request.path,
            port: request.port,
            query_string: request.query_string,
            remote_addr: request.remote_ip, # we insert this middleware after ActionDispatch::RemoteIp
            referrer: referrer,
            request_id: request.request_id, # we insert this middleware after ActionDispatch::RequestId
            scheme: request.scheme,
            user_agent: request.user_agent
          )
        end

        status, headers, body = @app.call(env)

        Config.instance.logger.info do
          time_ms = (Time.now - start) * 1000.0
          Events::HTTPServerResponse.new(
            status: status,
            time_ms: time_ms,
            additions: additions
          )
        end
      end

      private
        def request_id(request)


          env["X-Request-ID"] ||
            env["X-Request-Id"] ||
            env["action_dispatch.request_id"]
        end
    end
  end
end