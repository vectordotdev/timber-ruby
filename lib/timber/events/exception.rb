require "timber/events/error"

module Timber
  module Events
    # DEPRECATION: This class is deprecated in favor of using {Timber:Events:Error}.
    # @private
    class Exception < Error
    end
  end
end