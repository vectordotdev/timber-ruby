module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        initializer 'timber.bootstrap', after: :initialize_logger do |app|
          logger = ::Rails.logger
          if logger.nil?
            Config.logger.warn("Rails.logger is nil, can't install Timber")
          else
            Bootstrap.bootstrap!(logger, app.middleware)
          end
        end
      end
    end
  end
end
