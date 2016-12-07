module Timber
  class Context # :nodoc:
    def keyspace
      raise NoImplementedError.new
    end
  end
end