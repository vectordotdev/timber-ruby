module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        initializer 'timber.bootstrap', after: :load_config_initializers do |app|
          logger = app.logger

          # TODO: this overrides any custom loggers set in config. We
          # want to honor any custom logger they set, but default to the
          # rails logger if they dont.
          app.config.timber.logger = logger

          # Boot the boots!
          Bootstrap.bootstrap!(logger)
        end
      end
    end
  end
end
