module Timber
  module Frameworks
    # Module for Rails specific code, such as the Railtie and any methods that assist
    # with Rails setup.
    module Rails
      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        config.before_initialize do
          Timber::Config.instance.logger = Proc.new { ::Rails.logger }
        end

        after = defined?(Devise) ? 'devise.omniauth' : :load_config_initializers

        # Must be loaded after initializers so that we respect any Timber configuration
        # set
        initializer(:timber, before: :build_middleware_stack, after: after) do
          Integrations.integrate!

          # Install the Rack middlewares so that we capture structured data instead of
          # raw text logs.
          Integrations::Rack.middlewares.collect do |middleware_class|
            config.app_middleware.use middleware_class
          end
        end
      end
    end
  end
end
