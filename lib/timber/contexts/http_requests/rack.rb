require "timber/contexts/http_requests/rack/params"

module Timber
  module Contexts
    module HTTPRequests
      class Rack < HTTPRequest
        class Headers
          include Patterns::ToJSON

          attr_reader :env, :request

          def initialize(env, request)
            @env = env
            @request = request
          end

          def connect_time_ms
            @connect_time_ms ||= env["HTTP_CONNECT_TIME"]
          end

          def content_type
            @content_type ||= request.content_type
          end

          def referrer
            @referrer ||= request.referrer
          end

          def remote_addr
            @remote_addr ||= request.ip
          end

          def request_id
            return @request_id if defined?(@request_id)
            found = env.find do |k,v|
              # Needs to support:
              # action_dispatch.request_id
              # HTTP_X_REQUEST_ID
              # Request-ID
              # Request-Id
              # X-Request-ID
              # X-Request-Id
              # etc
              (k.downcase.include?("request_id") || k.downcase.include?("request-id")) && !v.nil?
            end
            @request_id = found && found.last
          end

          def user_agent
            @user_agent ||= request.user_agent
          end

          private
            def json_payload
              @json_payload ||= {
                :connect_time_ms => connect_time_ms,
                :content_type => content_type,
                :referrer => referrer,
                :remote_addr => remote_addr,
                :request_id => request_id,
                :user_agent => user_agent
              }
            end
        end

        attr_reader :env

        def initialize(env)
          # Initialize should be as fast as possible since it is executed inline.
          # Hence the lazy methods below.
          @env = env
          super()
        end

        def headers
          @headers ||= Headers.new(env, request)
        end

        def host
          @host ||= request.host
        end

        def method
          @method ||= request.request_method.upcase
        end

        def path
          @path ||= request.path
        end

        def port
          @port ||= request.port
        end

        def query_params
          @query_params ||= request.params && Params.new(request.params)
        end

        def scheme
          @scheme ||= request.scheme
        end

        private
          def request
            @request ||= ::Rack::Request.new(env)
          end
      end
    end
  end
end
