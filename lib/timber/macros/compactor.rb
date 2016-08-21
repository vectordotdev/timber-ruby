module Timber
  module Macros
    module Compactor
      def self.compact(hash)
        new_hash = {}
        hash.each do |k, v|
          deep_v = v.is_a?(Hash) ? compact(v) : v
          if !v.nil? && v != [] && v != {}
            new_hash[k] = v
          end
        end
        new_hash
      end
    end
  end
end