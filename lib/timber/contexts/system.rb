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
        @pid = Timber::Util::Object.try(attributes[:pid], :to_i)
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def as_json(_options = {})
        {hostname: hostname, pid: pid}
      end
    end
  end
end