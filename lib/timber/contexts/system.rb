require "timber/context"
require "timber/util"

module Timber
  module Contexts
    # The system context tracks OS level process information, such as the process ID.
    #
    # @note This is tracked automatically in {CurrentContext}. When the current context
    #   is initialized, the system context gets added automatically.
    class System < Context
      HOSTNAME_MAX_BYTES = 256.freeze

      @keyspace = :system

      attr_reader :hostname, :pid

      def initialize(attributes)
        normalizer = Util::AttributeNormalizer.new(attributes)
        @hostname = normalizer.fetch(:hostname, :string, :limit => HOSTNAME_MAX_BYTES)
        @pid = normalizer.fetch(:pid, :integer)
      end

      # Builds a hash representation containing simple objects, suitable for serialization (JSON).
      def to_hash
        @to_hash ||= Util::NonNilHashBuilder.build do |h|
          h.add(:hostname, hostname)
          h.add(:pid, pid)
        end
      end
    end
  end
end
