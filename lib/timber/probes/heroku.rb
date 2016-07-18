module Timber
  module Probes
    class Heroku < Probe
      class << self
        attr_accessor :inserted
      end

      def initialize
        if dyno.nil?
          raise RequirementNotMetError.new("The DYNO environment variable is not set. " +
            "Not in the Heroku environment.")
        end
      end

      def insert!
        return true if self.class.inserted == true
        context = Contexts::Heroku.new(dyno)
        # Note we don't use a block here, this is because
        # the context is persistent.
        CurrentContext.add(context)
        self.class.inserted = true
      end

      private
        def dyno
          ENV['DYNO']
        end
    end
  end
end
