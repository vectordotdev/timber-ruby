module Timber
  module Contexts
    # Tracks OS level process information, such as the process ID.
    class System < Context
      @keyspace = :system

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