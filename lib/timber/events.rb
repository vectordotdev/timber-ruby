module Timber
  module Events
    def self.build(obj)
      if obj.is_a?(Event)
        event
      elsif obj.respond_to?(:to_timber_event)
        event.to_timber_event
      elsif obj.is_a?(Hash)
        name = obj.fetch(:name)
        data = obj.fetch(:data)
        Events::Custom.new(name, data)
      else
        nil
      end
    end
  end
end