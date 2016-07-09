module Timber
  module Contexts
    class Logger < Context
      VERSION = "1".freeze
      KEY_NAME = "logger".freeze

      property :level, :progname

      def initialize(level, progname)
        @level = level
        @progname = progname
        super()
      end
    end
  end
end
