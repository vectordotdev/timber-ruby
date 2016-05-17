module Timber
  module Probes
    class Heroku < Probe
      def initialize
        if ENV['DYNO'].nil?
          raise RequirementUnsatisfiedError.new("The DYNO environment variable is not set")
        end
      end

      def insert!
        context = Contexts::Heroku.new
        CurrentContext.add(context)
      end
    end
  end
end
