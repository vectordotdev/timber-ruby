module Timber
  module Contexts
    class Heroku < Context
      VERSION = "1".freeze
      KEY_NAME = "heroku".freeze

      property :dyno

      def initialize(dyno)
        super()
        @dyno = dyno
      end
    end
  end
end
