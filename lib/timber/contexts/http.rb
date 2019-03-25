require "timber/context"

module Timber
  module Contexts
    # @private
    class HTTP < Context
      attr_reader :host, :method, :path, :remote_addr, :request_id

      def initialize(attributes)
        @host = attributes[:host]
        @method = attributes[:method]
        @path = attributes[:path]
        @remote_addr = attributes[:remote_addr]
        @request_id = attributes[:request_id]
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= {
          http: Util::NonNilHashBuilder.build do |h|
            h.add(:host, host)
            h.add(:method, method)
            h.add(:path, path)
            h.add(:remote_addr, remote_addr)
            h.add(:request_id, request_id)
          end
        }
      end
    end
  end
end
