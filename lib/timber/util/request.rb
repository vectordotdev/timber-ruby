begin
  require "rack"
rescue LoadError
end

if defined?(::Rack::Request)
  module Timber
    module Util
      # @private
      class Request < ::Rack::Request
        # We store strings as constants since they are reused on a per request basis.
        # This avoids string allocations.
        HTTP_HEADER_ORIGINAL_DELIMITER = '_'.freeze
        HTTP_HEADER_NEW_DELIMITER = '_'.freeze
        HTTP_PREFIX = 'HTTP_'.freeze

        REMOTE_IP_KEY_NAME = 'action_dispatch.remote_ip'.freeze
        REQUEST_ID_KEY_NAME1 = 'action_dispatch.request_id'.freeze
        REQUEST_ID_KEY_NAME2 = 'X-Request-ID'.freeze
        REQUEST_ID_KEY_NAME3 = 'X-Request-Id'.freeze

        def body_content
          content = body.read
          body.rewind
          content
        end

        # Returns a list of request headers. The rack env contains a lot of data, this function
        # identifies those that were the actual request headers.
        #
        # This was extracted from: https://github.com/ruby-grape/grape/blob/91c6c78ae3d3f3ffabaf57ffc4dc35ab7cfc7b5f/lib/grape/request.rb#L30
        def headers
          @headers ||= begin
            headers = {}

            @env.each_pair do |k, v|
              next unless k.is_a?(String) && k.to_s.start_with?(HTTP_PREFIX)

              k = k[5..-1].
                split(HTTP_HEADER_ORIGINAL_DELIMITER).
                each(&:capitalize!).
                join(HTTP_HEADER_NEW_DELIMITER)

              headers[k] = v
            end

            headers
          end
        end

        def ip
          @ip ||= if @env[REMOTE_IP_KEY_NAME]
            @env[REMOTE_IP_KEY_NAME].to_s || super
          else
            super
          end
        end

        def referer
          # Rails 3.X returns "/" for some reason
          @referer ||= super == "/" ? nil : super
        end

        def request_id
          @request_id ||= @env[REQUEST_ID_KEY_NAME1] ||
            @env[REQUEST_ID_KEY_NAME2] ||
            @env[REQUEST_ID_KEY_NAME3]
        end
      end
    end
  end
end