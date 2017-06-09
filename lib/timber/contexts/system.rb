require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # The system context tracks OS level process information, such as the process ID.
    #
    # @note This is tracked automatically in {CurrentContext}. When the current context
    #   is initialized, the system context gets added automatically.
    class System < Context
      @keyspace = :system

      attr_reader :hostname, :pid

      def initialize(attributes)
        @hostname = attributes[:hostname]
        @pid = attributes[:pid]
        @pid = @pid.to_s
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {hostname: hostname, pid: Timber::Util::Object.try(pid, :to_s)}
      end
    end
  end
end