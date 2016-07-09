module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        # Must come after load_config_initializers so that we honor any
        # config changes in a timber.rb initializer
        initializer 'timber.bootstrap', after: :load_config_initializers do |app|
          logger = ::Rails.logger
          if logger.nil?
            Config.logger.warn("Rails.logger is nil, can't install Timber")
          else
            # Needs to be inserted before ::Rails::Rack::Logger since that logs the
            # Started GET /path
            Bootstrap.bootstrap!(logger, app.middleware, ::Rails::Rack::Logger)
          end
        end
      end
    end
  end
end
