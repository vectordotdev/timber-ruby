module Timber
  module Probes
    class Probe
      class RequirementUnsatisfiedError < StandardError; end

      class << self
        def insert!
          new.insert!
          true
        # RequirementUnsatisfiedError is the only silent failure we support
        rescue RequirementUnsatisfiedError
          false
        end
      end

      def insert!
        raise NotImplementedError.new("You must implement #insert!")
      end
    end
  end
end
