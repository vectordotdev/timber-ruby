module Timber
  module Contexts
    class Logger < Context
      ROOT_KEY = :logger.freeze
      VERSION = 1.freeze
      LEVEL_MAP = {
        0 => "debug",
        1 => "info",
        2 => "warn",
        3 => "error",
        4 => "fatal"
      }
      UNKNOWN_LEVEL = "unknown"

      attr_reader :level, :progname

      def initialize(level, progname)
        @level = LEVEL_MAP[level] || UNKNOWN_LEVEL
        @progname = progname
        super()
      end

      private
        def json_payload
          @json_payload ||= Macros::DeepMerger.merge({
            # order is relevant for logfmt styling
            :level => level,
            :progname => progname
          }, super).freeze
        end
    end
  end
end
