module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        # Make timber available via rails config
        config.timber = Config.instance

        initializer 'timber.bootstrap', after: :load_config_initializers do |app|
          # Grab the rails logger
          logger = app.config.logger
          if logger.nil?
            Config.logger.warn("Rails logger is nil, can't install Timber")
            return
          end

          # TODO: this overrides any custom loggers set in config. We
          # want to honor any custom logger they set, but default to the
          # rails logger if they dont.
          app.config.timber.logger = logger

          # Bootitup!
          Bootstrap.bootstrap!(logger)
        end
      end
    end
  end
end
