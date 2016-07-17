module Timber
  module Contexts
    class Exception < Context
      VERSION = "1".freeze
      KEY_NAME = "exception".freeze

      attr_reader :exception
      property :backtrace, :class_name, :message

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

      def class_name
        @class_name ||= exception.class.name
      end

      def message
        @message ||= exception.message
      end
    end
  end
end
