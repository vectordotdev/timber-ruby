module Timber
  module Contexts
    # Tracks OS level process information, such as the process ID.
    class System < Context
      @keyspace = :system

      attr_reader :hostname, :pid

      def initialize(attributes)
        @hostname = attributes[:hostname]
        @pid = attributes[:pid]
        @pid = @pid.to_s
      end

      def as_json(_options = {})
        {hostname: hostname, pid: Timber::Util::Object.try(pid, :to_s)}
      end
    end
  end
end