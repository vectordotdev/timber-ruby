module Timber
  class Context
    def initialize(attributes)
      attributes.each do |key, value|
        instance_variable_set(:"@#{key}", value)
      end
      freeze # contexts are immutable
    end

    def context_key
      raise NoImplementedError.new()
    end
  end
end