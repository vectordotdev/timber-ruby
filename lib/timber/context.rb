module Timber
  # Base class for all `Timber::Contexts::*` classes.
  # @private
  class Context
    def to_hash
      raise(NotImplementedError.new)
    end
  end
end
