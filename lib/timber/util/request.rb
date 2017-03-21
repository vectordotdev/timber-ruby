require "rack"

module Timber
  module Util
    class Request < ::Rack::Request
      def body_content
        content = body.read
        body.rewind
        content
      end

      def headers
        @headers ||= ::Hash[*@env.select {|k,v| k.start_with? 'HTTP_'}
          .collect {|k,v| [k.sub(/^HTTP_/, ''), v]}
          .collect {|k,v| [k.split('_').collect(&:capitalize).join('-'), v]}
          .sort
          .flatten]
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