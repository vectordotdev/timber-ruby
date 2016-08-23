module Timber
  module Macros
    # Deep merges hash keys
    module DeepMerger
      def self.merge(first, second)
        merger = proc { |_key, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
        first.merge(second, &merger)
      end
    end
  end
end