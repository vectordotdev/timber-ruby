module Timber
  module Probes
    class Heroku < Probe
      def initialize
        if dyno.nil?
          raise RequirementNotMetError.new("The DYNO environment variable is not set. " +
            "Not in the Heroku environment.")
        end
      end

      def insert!
        context = Contexts::Heroku.new(dyno)
        # Note we don't use a block here, this is because
        # the context is persistent.
        CurrentContext.add(context)
      end

      private
        def dyno
          ENV['DYNO']
        end
    end
  end
end
