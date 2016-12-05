module Timber
  class Event
    def as_json
      raise NotImplementedError.new
    end

    def to_json(options = {})
      as_json().to_json(options)
    end
  end
end