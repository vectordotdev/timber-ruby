module Timber
  module RackMiddlewares
    # Reponsible for adding the HTTP context for applications that use `Rack`.
    class HTTPContext
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ::Rack::Request.new(env)
        context = Contexts::HTTP.new(
          method: request.request_method,
          path: request.path,
          remote_addr: request.ip,
          request_id: request_id(env)
        )
        CurrentContext.with(context) do
          @app.call(env)
        end
      end

      private
        def request_id(env)
          env["X-Request-ID"] ||
            env["X-Request-Id"] ||
            env["action_dispatch.request_id"]
        end
    end
  end
end