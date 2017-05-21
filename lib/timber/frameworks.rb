require "logger"

# Attempt to require Rails. We can not list it as a gem
# dependency because we want to support multiple frameworks.
begin
  require "rails"
rescue LoadError
end

if defined?(::Rails) && defined?(::Rails::Railtie)
  require "timber/frameworks/rails"
end

module Timber
  # Namespace for installing Timber into frameworks
  # @private
  module Frameworks
  end
end