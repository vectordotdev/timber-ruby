module Timber
  module Contexts
    # Tracks OS level process information, such as the process ID.
    class OSProcess < Context
      @keyspace = :os_process

      attr_reader :pid

      def initialize(attributes)
        @pid = attributes[:pid]
      end

      def as_json(_options = {})
        {pid: pid}
      end
    end
  end
end