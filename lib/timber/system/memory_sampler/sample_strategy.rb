module Timber
  module System
    class MemorySampler
      class SampleStrategy
        def sample
          raise NotImplementedError.new
        end
      end
    end
  end
end
