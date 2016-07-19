module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        # Must come after load_config_initializers so that we honor any
        # config changes in a timber.rb initializer
        initializer 'timber.bootstrap', after: :load_config_initializers do |app|
          puts "Attempting Timber bootstrap"
          Bootstrap.bootstrap!(app.middleware, ::Rails::Rack::Logger)
        end
      end
    end
  end
end
