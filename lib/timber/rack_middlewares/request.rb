module Timber
  module RackMiddlewares
    class Request < ::Rack::Request
      def ip
        get_header("action_dispatch.remote_ip") || super
      end

      def referer
        # Rails 3.X returns "/" for some reason
        super == "/" ? nil : super
      end

      def request_id
        get_header("action_dispatch.request_id") || get_header("X-Request-ID") ||
          get_header("X-Request-Id")
      end
    end
  end
end