require "set"

require "timber/config"
require "timber/contexts/http"
require "timber/current_context"
require "timber/events/http_request"
require "timber/events/http_response"
require "timber/integrations/rack/middleware"

module Timber
  module Integrations
    module Rack
      # A Rack middleware that is reponsible for capturing and logging HTTP server requests and
      # response events. The {Events::HTTPRequest} and {Events::HTTPResponse} events
      # respectively.
      class HTTPEvents < Middleware
        class << self
          # Allows you to capture the HTTP request body, default is off (false).
          #
          # Capturing HTTP bodies can be extremely helpful when debugging issues,
          # but please proceed with caution:
          #
          # 1. Capturing HTTP bodies can use quite a bit of data (this can be mitigated, see below)
          # 2. The {Events::ControllerCall} event captures the parsed parmaters sent to
          #    the controller. This is a parsed representation of the body, which is usually more
          #    helpful and redundant to the body captured here.
          #
          # If you opt to capture bodies, you can also truncate the size to reduce the data
          # captured. See {Events::HTTPRequest}.
          #
          # @example
          #   Timber::Integrations::Rack::HTTPEvents.capture_request_body = true
          def capture_request_body=(value)
            @capture_request_body = value
          end

          # Accessor method for {#capture_request_body=}
          def capture_request_body?
            @capture_request_body == true
          end

          # Just like {#capture_request_body=} but for the {Events::HTTPResponse} event.
          # Please see {#capture_request_body=} for more details. The documentation there also
          # applies here.
          def capture_response_body=(value)
            @capture_response_body = value
          end

          # Accessor method for {#capture_response_body=}
          def capture_response_body?
            @capture_response_body == true
          end

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
          # The single event is still a {Timber::Events::HTTPResponse} event. Because
          # we capture HTTP context, you still get the HTTP details, but you will not get
          # all of the request details that the {Timber::Events::HTTPRequest} event would
          # provide.
          #
          # @example
          #   Timber::Integrations::Rack::HTTPEvents.collapse_into_single_event = true
          def collapse_into_single_event=(value)
            @collapse_into_single_event = value
          end

          # Accessor method for {#collapse_into_single_event=}.
          def collapse_into_single_event?
            @collapse_into_single_event == true
          end

          # This setting allows you to silence requests based on any conditions you desire.
          # We require a block because it gives you complete control over how you want to
          # silence requests. The first parameter being the traditional Rack env hash, the
          # second being a [Rack Request](http://www.rubydoc.info/gems/rack/Rack/Request) object.
          #
          # @example
          #   Integrations::Rack::HTTPEvents.silence_request = lambda do |rack_env, rack_request|
          #     rack_request.path == "/_health"
          #   end
          def silence_request=(proc)
            if proc && !proc.is_a?(Proc)
              raise ArgumentError.new("The value passed to #silence_request must be a Proc")
            end

            @silence_request = proc
          end

          # Accessor method for {#silence_request=}
          def silence_request
            @silence_request
          end
        end

        CONTENT_LENGTH_KEY = 'Content-Length'.freeze

        def call(env)
          request = Util::Request.new(env)

          if silenced?(env, request)
            if Config.instance.logger.respond_to?(:silence)
              Config.instance.logger.silence do
                @app.call(env)
              end
            else
              @app.call(env)
            end

          elsif collapse_into_single_event?
            start = Time.now

            status, headers, body = @app.call(env)

            Config.instance.logger.info do
              http_context_key = Contexts::HTTP.keyspace
              http_context = CurrentContext.fetch(http_context_key)
              content_length = headers[CONTENT_LENGTH_KEY]
              time_ms = (Time.now - start) * 1000.0

              Events::HTTPResponse.new(
                content_length: content_length,
                headers: headers,
                http_context: http_context,
                request_id: request.request_id,
                status: status,
                time_ms: time_ms
              )
            end

            [status, headers, body]

          else
            start = Time.now

            Config.instance.logger.info do
              event_body = capture_request_body? ? request.body_content : nil

              Events::HTTPRequest.new(
                body: event_body,
                content_length: request.content_length,
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
              event_body = capture_response_body? ? body : nil
              content_length = headers[CONTENT_LENGTH_KEY]
              time_ms = (Time.now - start) * 1000.0

              Events::HTTPResponse.new(
                body: event_body,
                content_length: content_length,
                headers: headers,
                request_id: request.request_id,
                status: status,
                time_ms: time_ms
              )
            end

            [status, headers, body]
          end
        end

        private
          def capture_request_body?
            self.class.capture_request_body?
          end

          def capture_response_body?
            self.class.capture_response_body?
          end

          def collapse_into_single_event?
            self.class.collapse_into_single_event?
          end

          def silenced?(env, request)
            if !self.class.silence_request.nil?
              self.class.silence_request.call(env, request)
            else
              false
            end
          end
      end
    end
  end
end