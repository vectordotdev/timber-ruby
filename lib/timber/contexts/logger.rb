module Timber
  module Contexts
    class Logger < Context
      ROOT_KEY = :logger.freeze
      VERSION = 1.freeze

      attr_reader :level, :progname

      def initialize(level, progname)
        @level = level
        @progname = progname
        super()
      end

      private
        def json_payload
          @json_payload ||= Core::DeepMerger.merge({
            _root_key => {
              :level => level,
              :progname => progname
            }
          }, super)
        end
    end
  end
end
