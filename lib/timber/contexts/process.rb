module Timber
  module Contexts
    class Process < Context
      VERSION = "1".freeze
      NAME = "process".freeze
      MEMORY_SAMPLER_CACHE_LENGTH_MS = 500.freeze

      attr_reader :memory_bytes, :pid

      class << self
        # Cache the memory sampler to avoid the overhead of initiating
        # a sampler for each log line.
        def memory_sampler
          @memory_sampler ||= System::MemorySampler.new(MEMORY_SAMPLER_CACHE_LENGTH_MS)
        end
      end

      def initialize
        super
        @memory_bytes = memory_sampler.bytes
        @pid = ::Process.pid
      end

      def to_hash
        super.merge(
          :memory_bytes => memory_bytes,
          :pid => pid
        )
      end

      private
        def memory_sampler
          self.class.memory_sampler
        end
    end
  end
end
