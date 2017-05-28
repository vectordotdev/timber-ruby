require "timber/integrations/rack/middleware"

module Timber
  module Integrations
    module Rack
      # A Rack middleware that is reponsible for adding the HTTP context {Timber::Contexts::HTTP}.
      class HTTPContext < Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          request = Util::Request.new(env)
          context = Contexts::HTTP.new(
            method: request.request_method,
            path: request.path,
            remote_addr: request.ip,
            request_id: request.request_id
          )
          CurrentContext.with(context) do
            @app.call(env)
          end
        end
      end
    end
  end
end