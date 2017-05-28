require "timber/integrations/rack/middleware"

module Timber
  module Integrations
    module Rack
      # A Rack middleware that is reponsible for capturing and logging HTTP server requests and
      # response events. The {Timber::Events::HTTPServerRequest} and
      # {Timber::Events::HTTPServerResponse} events respectively.
      class HTTPEvents < Middleware
        class << self
          # Collapse both the HTTP request and response events into a single log line event.
          # While we don't recommend this, it can help to reduce log volume if desired.
          # The reason we don't recommend this, is because the logging service you use should
          # not be so expensive that you need to strip out useful logs. It should also provide
          # the tools necessary to properly search your logs and reduce noise. Such as viewing
          # logs for a specific request.
          #
          # To provide an example. This setting turns this:
          #
          #   Started GET "/" for 127.0.0.1 at 2012-03-10 14:28:14 +0100
          #   Completed 200 OK in 79ms (Views: 78.8ms | ActiveRecord: 0.0ms)
          #
          # Into this:
          #
          #   Get "/" sent 200 OK in 79ms
          #
          # The single event is still a {Timber::Events::HTTPServerResponse} event. Because
          # we capture HTTP context, you still get the HTTP details, but you will not get
          # all of the request details that the {Timber::Events::HTTPServerRequest} event would
          # provide.
          #
          # @example
          #   Timber::Integrations::Rack::HTTPEvents.collapse_into_single_event = true
          def collapse_into_single_event=(value)
            @collapse_into_single_event = value
          end

          # Accessor method for {#collapse_into_single_event=}.
          def collapse_into_single_event
            @collapse_into_single_event
          end
        end

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
              http_context: CurrentContext.fetch(:http),
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