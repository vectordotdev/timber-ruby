module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        initializer 'timber.configure' do |app|
          Bootstrap.bootstrap!
        end
      end
    end
  end
end
