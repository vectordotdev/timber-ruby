module Timber
  class Context
    def keyspace
      raise NoImplementedError.new
    end
  end
end