module Timber
  class Event # :nodoc:
    def as_json(options = {})
      raise NotImplementedError.new
    end

    def to_json(options = {})
      Util::Hash.compact(as_json).to_json(options)
    end
  end
end