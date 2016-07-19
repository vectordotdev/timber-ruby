module Timber
  module Frameworks
    module Rails
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance
        config.before_initialize do
          ::Rails.logger = config.logger = ActiveSupport::TaggedLogging.new(Timber::Logger.new)
          Bootstrap.bootstrap!(config.app_middleware, ::Rails::Rack::Logger)
        end

        # Must come after load_config_initializers so that we honor any
        # config changes in a timber.rb initializer
        # initializer 'timber.bootstrap', after: :load_config_initializers do |app|
        #   Bootstrap.bootstrap!(app.middleware, ::Rails::Rack::Logger)
        # end
      end
    end
  end
end
