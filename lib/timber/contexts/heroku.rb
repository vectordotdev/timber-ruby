module Timber
  module Contexts
    class Heroku < Context
      VERSION = "1".freeze
      KEY_NAME = "heroku".freeze
      DELIMITER = "."

      property :dyno_type, :dyno_id
      attr_reader :dyno

      def initialize(dyno)
        @dyno = dyno
        super()
      end

      def dyno_type
        @dyno_type ||= parts.first
      end

      def dyno_id
        @dyno_id ||= parts.last
      end

      private
        def parts
          @parts ||= dyno.split(DELIMITER)
        end
    end
  end
end
