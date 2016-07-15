require "timber/contexts/rack_request/params"

module Timber
  module Contexts
    class RackRequest < HTTPRequest
      attr_reader :env

      def initialize(env)
        # Initialize should be as fast as possible since it is executed inline.
        # Hence the lazy methods below.
        @env = env
        super()
      end

      def connect_time_ms
        @connect_time_ms ||= env["HTTP_CONNECT_TIME"]
      end

      def content_type
        @content_type ||= request.content_type
      end

      def host
        @host ||= request.host
      end

      def ip
        @ip ||= request.ip
      end

      def method
        @method ||= request.request_method
      end

      def params
        @params ||= request.params && Params.new(request.params)
      end

      def path
        @path ||= request.path
      end

      def port
        @port ||= request.port
      end

      def referrer
        @referrer ||= request.referrer
      end

      def request_id
        @request_id ||= env["HTTP_X_REQUEST_ID"] || env["action_dispatch.request_id"]
      end

      def scheme
        @scheme ||= request.scheme
      end

      def user_agent
        @user_agent ||= request.user_agent
      end

      private
        def request
          @request ||= ::Rack::Request.new(env)
        end
    end
  end
end
