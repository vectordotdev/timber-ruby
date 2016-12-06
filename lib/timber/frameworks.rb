require "logger"

# Attempt to require Rails. We can not list it as a gem
# dependency because we want to support multiple frameworks.
require("rails") rescue LoadError

if defined?(Rails)
  require 'timber/frameworks/rails'
end

module Timber
  module Frameworks # :nodoc:
    def self.logger(logdev)
      if defined?(Timber::Frameworks::Rails)
        Rails.logger(logdev)
      else
        ::Logger.new(logdev)
      end
    end
  end
end