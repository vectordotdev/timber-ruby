require "timber/system/memory_sampler/sample_strategy"
require "timber/system/memory_sampler/java_heap_sample_strategy"
require "timber/system/memory_sampler/proc_status_sample_strategy"
require "timber/system/memory_sampler/ps_sample_strategy"

module Timber
  module System
    class MemorySampler
      class UnknownPlatformError < StandardError; end

      # cache_length avoids bombarding the system with memory sampling
      def initialize(cache_length_ms = nil)
        @cache_length_ms = nil
      end

      def bytes
        @bytes = nil if expire_bytes?
        @bytes ||= sample_strategy.bytes.tap do
          @bytes_memoized_at = Time.now
        end
      end

      private
        def cache_length_ms
          @cache_length_ms
        end

        def bytes_memoized_at
          @bytes_memoized_at
        end

        def expire_bytes?
          @bytes.nil? ||
            cache_length_ms.nil? ||
            bytes_memoized_at.nil? ||
            ((Time.now - bytes_memoized_at) * 1000) >= cache_length_ms
        end

        def sample_strategy
          @sample_strategy ||= if jruby?
            JavaHeapSampleStrategy.new
          elsif Platform.linux? || Platform.darwin?
            PSSampleStrategy.new
          else
            raise UnknownPlatformError.new
          end
        end

        def jruby?
          defined?(JRuby)
        end
    end
  end
end
