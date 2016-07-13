module Timber
  module Contexts
    class Rack < HTTPRequest
      def initialize(env)
        request = ::Rack::Request.new(env)
        @connect_time_ms = env["HTTP_CONNECT_TIME"]
        @content_type = request.content_type
        @host = request.host
        @ip = request.ip
        @method = request.request_method
        @params = request.params
        @path = request.path
        @port = request.port
        @referrer = request.referrer
        @request_id = env["HTTP_X_REQUEST_ID"] || env["action_dispatch.request_id"]
        @scheme = request.scheme
        @user_agent = request.user_agent
        super()
      end
    end
  end
end
