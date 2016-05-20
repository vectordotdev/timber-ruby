module Timber
  module System
    class MemorySampler
      class JavaHeapSampleStrategy < SampleStrategy
        def sample
          java.lang.Runtime.getRuntime.totalMemory / (1024 * 1024).to_f
        end
      end
    end
  end
end
