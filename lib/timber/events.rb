require "timber/events/controller_call"
require "timber/events/custom"
require "timber/events/error"
require "timber/events/http_request"
require "timber/events/http_response"
require "timber/events/sql_query"
require "timber/events/template_render"

module Timber
  # Namespace for all Timber supported events.
  module Events
    # Protocol for casting objects into a `Timber::Event`.
    #
    # @example Casting a hash
    #   Timber::Events.build({message: "My log message", event_type: {key: "value"}})
    def self.build(obj)
      if obj.is_a?(::Timber::Event)
        obj
      elsif obj.respond_to?(:to_timber_event)
        obj.to_timber_event
      elsif obj.is_a?(Hash) && obj.key?(:message)
        event_hash = obj.select { |k,v| k != :message }

        if event_hash.length == 1 && event_hash.values.first.is_a?(Hash)
          type = event_hash.keys.first
          data = event_hash.values.first

          Events::Custom.new(
            type: type,
            message: obj[:message],
            data: data
          )
        else
          nil
        end

      elsif obj.is_a?(Struct) && obj.respond_to?(:message) && obj.respond_to?(:type)
        Events::Custom.new(
          type: obj.type,
          message: obj.message,
          data: obj.respond_to?(:to_h) ? obj.to_h : Timber::Util::Struct.to_hash(obj) # ruby 1.9.3 does not have to_h :(
        )
      else
        nil
      end
    end
  end
end