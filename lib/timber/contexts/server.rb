require "socket"

module Timber
  module Contexts
    class Server < Context
      ROOT_KEY = :server.freeze
      VERSION = 1.freeze

      def hostname
        @hostname ||= ::Socket.gethostname
      end

      private
        def json_payload
          @json_payload ||= Macros::DeepMerger.merge({
            :hostname => hostname
          }, super)
        end
    end
  end
end
