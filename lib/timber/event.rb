module Timber
  class Event # :nodoc:
    def as_json
      raise NotImplementedError.new
    end

    def to_json(options = {})
      hash = as_json.select do |key, value|
        !value.nil?
      end
      hash.to_json(options)
    end
  end
end