begin
  require "rack"
rescue LoadError
end

if defined?(::Rack::Request)
  module Timber
    module Util
      # @private
      class Request < ::Rack::Request
        HTTP_PREFIX = 'HTTP_'.freeze

        def body_content
          content = body.read
          body.rewind
          content
        end

        # Returns a list of request headers. The rack env contains a lot of data, this function
        # identifies those that were the actual request headers.
        def headers
          @headers ||= ::Hash[
            *@env.select { |k,v| k.is_a?(String) && k.start_with?(HTTP_PREFIX) }
              .collect { |k,v| [k.sub(/^#{HTTP_PREFIX}/, ''), v] }
              .collect { |k,v| [k.split('_').collect(&:capitalize).join('-'), v] }
              .sort
              .flatten
          ]
        end

        def ip
          @ip ||= if @env["action_dispatch.remote_ip"]
            @env["action_dispatch.remote_ip"].to_s || super
          else
            super
          end
        end

        def referer
          # Rails 3.X returns "/" for some reason
          @referer ||= super == "/" ? nil : super
        end

        def request_id
          @request_id ||= @env["action_dispatch.request_id"] || @env["X-Request-ID"] ||
            @env["X-Request-Id"]
        end
      end
    end
  end
end