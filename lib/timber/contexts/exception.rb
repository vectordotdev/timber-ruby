module Timber
  module Contexts
    class Exception < Context
      ROOT_KEY = :exception.freeze
      VERSION = 1.freeze

      attr_reader :exception

      def initialize(exception)
        # Initialize should be as fast as possible since it is executed inline.
        # Hence the lazy methods below.
        @exception = exception
        super()
      end

      def backtrace
        # only the first 5 lines to save on space
        @backtrace ||= exception.backtrace[0..5]
      end

      def name
        @name ||= exception.class.name
      end

      def message
        @message ||= exception.message
      end

      private
        def json_payload
          @json_payload ||= Macros::DeepMerger.merge({
            # order is relevant for logfmt styling
            :name => name,
            :message => message
          }, super)
        end
    end
  end
end
