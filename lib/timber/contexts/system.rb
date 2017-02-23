module Timber
  module Contexts
    # Tracks OS level process information, such as the process ID.
    class System < Context
      @keyspace = :system

      attr_reader :pid

      def initialize(attributes)
        @pid = attributes[:pid] || raise(ArgumentError.new(":pid is required"))
        @pid = @pid.to_s
      end

      def as_json(_options = {})
        {pid: Timber::Util::Object.try(pid, :to_s)}
      end
    end
  end
end