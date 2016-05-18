module Timber
  module Probes
    class Heroku < Probe
      def initialize
        if ENV['DYNO'].nil?
          raise RequirementNotMetError.new("The DYNO environment variable is not set")
        end
      end

      def insert!
        context = Contexts::Heroku.new
        # Note we don't use a block here, this is because
        # the context is persistent.
        CurrentContext.add(context)
      end
    end
  end
end
