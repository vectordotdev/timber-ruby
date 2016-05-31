module Timber
  module Contexts
    class Logger < Context
      VERSION = "1".freeze
      NAME = "logger".freeze

      attr_reader :level

      def initialize(level, progname)
        super()
        @level = level
        @progname = progname
      end

      def to_hash
        super.merge(:level => level).tap do |hash|
          if progname
            hash[:progname] = progname
          end
        end
      end
    end
  end
end
