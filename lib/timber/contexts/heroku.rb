module Timber
  module Contexts
    class Heroku < Context
      VERSION = "1".freeze
      KEY_NAME = "heroku".freeze
      DELIMITER = "."

      property :dyno_type, :dyno_id

      def initialize(dyno)
        dyno_type, dyno_id = dyno.split(DELIMITER)
        @dyno_type = dyno_type
        @dyno_id = dyno_id
        super()
      end
    end
  end
end
