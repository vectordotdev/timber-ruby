module Timber
  class Probe #:nodoc:
    class RequirementNotMetError < StandardError; end

    class << self
      def insert!(*args)
        new(*args).insert!
        Config.instance.logger.debug("Inserted probe #{name}")
        true
      # RequirementUnsatisfiedError is the only silent failure we support
      rescue RequirementNotMetError => e
        Config.instance.logger.debug("Failed inserting probe #{name}: #{e.message}")
        false
      end
    end

    def insert!
      raise NotImplementedError.new
    end
  end
end