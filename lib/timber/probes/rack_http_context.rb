module Timber
  module Probes
    class RackHTTPContext < Probe
      class Middleware
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
          CurrentContext.with(context.key, context) do
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

      attr_reader :middleware, :insert_before

      def initialize(middleware, insert_before)
        if middleware.nil?
          raise RequirementNotMetError.new("The middleware class attribute is not set. " +
            "We need a middleware to insert the probe.")
        end
        @middleware = middleware
        @insert_before = insert_before
      end

      def insert!
        return true if middleware.instance_variable_get(:"@_timber_inserted") == true
        # Rails uses a proxy :/, so we need to do this instance variable hack
        middleware.instance_variable_set(:"@_timber_inserted", true)
        middleware.insert_before insert_before, Middleware
      end
    end
  end
end