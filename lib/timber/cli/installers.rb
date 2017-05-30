# Attempt to load rails so that we can determine the proper installer to use.
begin
  require "rails"
rescue LoadError
end

require "timber/cli/installers/generic"
require "timber/cli/installers/rails"

module Timber
  class CLI
    module Installers
      def self.find
        if defined?(::Rails)
          Rails.new
        else
          Generic.new
        end
      end
    end
  end
end