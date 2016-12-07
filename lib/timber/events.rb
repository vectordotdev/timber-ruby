require "timber/events/controller_call"
require "timber/events/custom"
require "timber/events/exception"
require "timber/events/http_request"
require "timber/events/http_response"
require "timber/events/sql_query"
require "timber/events/template_render"

module Timber
  module Events #:nodoc:
    def self.build(obj)
      if obj.is_a?(::Timber::Event)
        obj
      elsif obj.respond_to?(:to_timber_event)
        obj.to_timber_event
      elsif obj.is_a?(Hash) && obj.key?(:message) && obj.key?(:type) && obj.key?(:data)
        Events::Custom.new(
          type: obj[:type],
          message: obj[:message],
          data: obj[:data]
        )
      elsif obj.is_a?(Struct) && obj.respond_to?(:message) && obj.respond_to?(:type)
        Events::Custom.new(
          type: obj.type,
          message: obj.message,
          data: obj.respond_to?(:hash) ? obj.hash : obj.to_h # ruby 1.9.3 does not have to_h
        )
      else
        nil
      end
    end
  end
end