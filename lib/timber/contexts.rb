require "timber/contexts/custom"
require "timber/contexts/http"
require "timber/contexts/organization"
require "timber/contexts/release"
require "timber/contexts/runtime"
require "timber/contexts/session"
require "timber/contexts/system"
require "timber/contexts/user"

module Timber
  # Namespace for all Timber supported Contexts.
  module Contexts
    # Protocol for casting objects into a {Timber::Context}.
    #
    # @example Casting a hash
    #   Timber::Contexts.build(deploy: {version: "1.0.0"})
    def self.build(obj)
      if obj.is_a?(::Timber::Context)
        obj
      elsif obj.respond_to?(:to_timber_context)
        obj.to_timber_context
      elsif obj.is_a?(Hash) && obj.length == 1
        type = obj.keys.first
        data = obj.values.first

        Contexts::Custom.new(
          type: type,
          data: data
        )
      elsif obj.is_a?(Struct) && obj.respond_to?(:type)
        Contexts::Custom.new(
          type: obj.type,
          data: obj.respond_to?(:to_h) ? obj.to_h : Timber::Util::Struct.to_hash(obj) # ruby 1.9.3 does not have to_h
        )
      else
        nil
      end
    end
  end
end