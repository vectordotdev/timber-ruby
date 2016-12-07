module Timber
  module Util
    module Hash #:nodoc:
      extend self

      def compact(hash)
        hash.select do |k, v|
          v != nil && v != {} && v != []
        end
      end
    end
  end
end