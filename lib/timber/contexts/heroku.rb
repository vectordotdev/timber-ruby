module Timber
  module Contexts
    class Heroku < Context
      VERSION = "1".freeze
      NAME = "heroku".freeze

      attr_reader :dyno

      def initialize(dyno)
        super()
        @dyno = dyno
      end

      def to_hash
        super.merge(:dyno => dyno)
      end
    end
  end
end
