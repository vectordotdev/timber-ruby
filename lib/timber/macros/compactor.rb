module Timber
  module Macros
    module Compactor
      def self.compact(hash)
        new_hash = {}
        hash.each do |k, v|
          deep_v = v.is_a?(Hash) ? compact(v) : v
          if !deep_v.nil? && deep_v != [] && deep_v != {}
            new_hash[k] = deep_v
          end
        end
        new_hash
      end
    end
  end
end