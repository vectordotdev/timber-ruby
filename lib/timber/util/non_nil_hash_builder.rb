require 'json'

module Timber
  module Util
    # @private
    #
    # The purpose of this class is to efficiently build a hash that does not
    # include nil values. It's proactive instead of reactive, avoiding the
    # need to traverse and reduce a new hash dropping blanks.
    class NonNilHashBuilder
      class << self
        def build(&block)
          builder = new
          yield builder
          builder.target
        end
      end

      attr_reader :target

      def initialize
        @target = {}
      end

      def add(k, v, options = {})
        if !v.nil?
          if options[:json_encode]
            v = v.to_json
          end

          if options[:limit]
            v = v.byteslice(0, options[:limit])
          end

          @target[k] = v
        end
      end
    end
  end
end
