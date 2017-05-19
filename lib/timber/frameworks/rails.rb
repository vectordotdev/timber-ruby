module Timber
  module Frameworks
    # Module for Rails specific code, such as the Railtie and any methods that assist
    # with Rails setup.
    module Rails
      # Because of the crazy way Rails sorts it's initializers, it is
      # impossible for Timber to be inserted after Devise's omnitauth
      # middlewares.
      # See: https://github.com/plataformatec/devise/blob/master/lib/devise/rails.rb#L22
      # As such, we take a brute force approach here, ensuring we are inserted last
      # no matter what. This ensures that we come after authentication so that we can
      # properly set the user context.
      #
      # @private
      module MiddlewareStackProxyFix
        def self.included(klass)
          klass.class_eval do
            attr_accessor :timber_operations

            alias old_merge_into merge_into

            # This method does not exist for older versions of rails
            begin
              alias old_plus +
            rescue NameError
            end

            def +(*args)
              result = old_plus(*args)
              result.timber_operations = timber_operations
              result
            end

            def merge_into(*args)
              if timber_operations
                @operations -= timber_operations
                @operations += timber_operations
              end
              old_merge_into(*args)
            end
          end
        end
      end

      ::Rails::Configuration::MiddlewareStackProxy.send(:include, MiddlewareStackProxyFix)

      # Installs Timber into your Rails app automatically.
      class Railtie < ::Rails::Railtie
        config.timber = Config.instance

        initializer(:timber, after: :initialize_logger) do
          Timber::Config.instance.logger = Proc.new { ::Rails.logger }
          Integrations.integrate!

          timber_operations = Integrations::Rack.middlewares.collect do |middleware_class|
            [:use, [middleware_class], nil]
          end

          config.app_middleware.timber_operations = timber_operations
        end
      end
    end
  end
end