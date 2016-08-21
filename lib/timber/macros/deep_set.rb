module Timber
  module Macros
    module DeepSet
      def set(hash, path, value)
        keys = path.split(".")
        target_hash = keys[0..-2].inject(hash) do |acc, key|
          acc[key.to_sym] || raise("could not find key #{value.inspect} for #{hash}")
        end
        target_hash[keys.last] = value
      end
    end
  end
end