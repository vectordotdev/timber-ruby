module Timber
  class Probe
    class RequirementNotMetError < StandardError; end

    class << self
      def insert!(*args)
        new(*args).insert!
        Config.logger.debug("Inserted probe #{name}")
        true
      # RequirementUnsatisfiedError is the only silent failure we support
      rescue RequirementNotMetError => e
        Config.logger.debug("Failed inserting probe #{name}: #{e.message}")
        false
      end
    end

    def insert!
      raise NotImplementedError.new("You must implement #insert")
    end
  end
end