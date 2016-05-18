module Timber
  class Probe
    class RequirementNotMetError < StandardError; end

    class << self
      def insert!
        new.insert!
        true
      # RequirementUnsatisfiedError is the only silent failure we support
      rescue RequirementNotMetError
        false
      end
    end

    def insert!
      raise NotImplementedError.new("You must implement #insert!")
    end
  end
end
