module Timber
  module Core
    module DateFormatter
      def self.format(dt)
        dt.send(APISettings::DATE_FORMAT, APISettings::DATE_FORMAT_PRECISION)
      end
    end
  end
end