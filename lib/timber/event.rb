module Timber
  # Base class for `Timber::Events::*`
  # @private
  class Event
    def message
      raise NotImplementedError.new
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