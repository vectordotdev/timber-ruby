require "timber/contexts/custom"
require "timber/contexts/http"
require "timber/contexts/organization"
require "timber/contexts/os_process"
require "timber/contexts/runtime"
require "timber/contexts/tags"
require "timber/contexts/user"

module Timber
  # Namespace for all Timber supported Contexts.
  module Contexts
    # Protocol for casting objects into a `Timber::Context`.
    #
    # @example Casting a hash
    #   Timber::Contexts.build({type: :build, data: {version: "1.0.0"}})
    def self.build(obj)
      if obj.is_a?(::Timber::Context)
        obj
      elsif obj.respond_to?(:to_timber_context)
        obj.to_timber_context
      elsif obj.is_a?(Hash) && obj.key?(:type) && obj.key?(:data)
        Contexts::Custom.new(
          type: obj[:type],
          data: obj[:data]
        )
      elsif obj.is_a?(Struct) && obj.respond_to?(:type)
        Events::Custom.new(
          type: obj.type,
          data: obj.respond_to?(:hash) ? obj.hash : obj.to_h # ruby 1.9.3 does not have to_h
        )
      else
        nil
      end
    end
  end
end