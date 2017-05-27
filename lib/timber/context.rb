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

    # Efficiently turn this content into JSON. We use a cache because context is
    # shared across log lines. The cache prevents multiple to_json calls.
    def to_json(options = {})
      return @to_json_cache[options] if @to_json_cache && @to_json_cache[options]
      @to_json_cache ||= {}
      @to_json_cache[options] = as_json.to_json(options)
    end

    # Efficiently turn this content into msgpack. We use a cache because context is
    # shared across log lines. The cache prevents multiple to_msgpack calls.
    def to_msgpack(*args)
      return @to_msgpack_cache[args] if @to_msgpack_cache && @to_msgpack_cache[args]
      @to_msgpack_cache ||= {}
      @to_msgpack_cache[args] = as_json.to_msgpack(*args)
    end
  end
end