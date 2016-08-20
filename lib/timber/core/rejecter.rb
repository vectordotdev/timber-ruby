module Timber
  module Core
    # Rejects keys from a hash. 2 points:
    # 1. While ActiveSupport has this, we need to support apps without ActiveSupport.
    # 2. We do not want to pollute the global space by modifying Hash directly.
    module Rejecter
      def self.reject(hash, keys)
        if keys.nil? or keys == []
          return hash
        else
          hash.reject { |key, value| keys.include?(key) }
        end
      end
    end
  end
end