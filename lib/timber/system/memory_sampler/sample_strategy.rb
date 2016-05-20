module Timber
  module System
    class MemorySampler
      class SampleStrategy
        def bytes
          raise NotImplementedError.new
        end
      end
    end
  end
end
