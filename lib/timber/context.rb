module Timber
  # Base class for all `Timber::Contexts::*` classes.
  # @private
  class Context
    class << self
      def keyspace
        @keyspace || raise(NotImplementedError.new)
      end
    end

    def keyspace
      self.class.keyspace
    end

    def as_json(options = {})
      raise NotImplementedError.new
    end

    def to_json(options = {})
      as_json.to_json(options)
    end

    def to_msgpack(*args)
      as_json.to_msgpack(*args)
    end
  end
end