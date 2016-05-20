module Timber
  module Contexts
    class Logger < Context
      VERSION = "1".freeze
      NAME = "logger".freeze

      attr_reader :level

      def initialize(level)
        super
        @level = level
      end

      def to_hash
        super.merge(:level => level)
      end
    end
  end
end
