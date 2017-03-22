require "logger"

# Attempt to require the Rails framework file.
begin
  require 'timber/frameworks/rails'
rescue Exception
end

module Timber
  # Namespace for installing Timber into frameworks
  # @private
  module Frameworks
  end
end