module Timber
  module Contexts
    class Heroku < Context
      VERSION = "1"
      
      attr_reader :dyno

      def initialize
        super
        @dyno = ENV['DYNO']
      end

      def to_hash
        super.merge(:dyno => dyno)
      end
    end
  end
end
