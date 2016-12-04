module Timber
  module Contexts
    class HTTP < Context
      attr_reader :method, :path, :remote_addr, :request_id

      def context_key
        :http
      end
    end
  end
end