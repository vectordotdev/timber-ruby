module Timber
  module Contexts
    class Heroku < Context
      VERSION = "1".freeze
      KEY_NAME = "heroku".freeze

      attr_reader :dyno

      def initialize(dyno)
        super()
        @dyno = dyno
      end

      def hash
        # Contexts are immutable. Cache the hash for performance reasons.
        @hash ||= super.merge(:dyno => dyno)
      end
    end
  end
end
