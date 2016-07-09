module Timber
  module Contexts
    class HTTPRequest < Context
      VERSION = "1".freeze
      KEY_NAME = "http_request".freeze

      property :connect_time,
        :content_type,
        :host,
        :ip,
        :method,
        :params,
        :path,
        :port,
        :referrer,
        :request_id,
        :scheme,
        :user_agent

      def initialize
        # Check to make sure the class was initialized properly
        if initialized_improperly?
          raise NotImplementedError.new(
            "This is an abstract class and initialization must be implement via subclasses"
          )
        end
        super()
      end

      private
        def initialized_improperly?
          host.nil?
        end
    end
  end
end
