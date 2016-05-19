require 'timber'
require 'rails'

module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        initializer 'timber.configure' do |app|
          Probes.insert!
        end
      end
    end
  end
end
