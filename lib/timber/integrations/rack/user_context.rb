module Timber
  module Integrations
    module Rack
      # Reponsible for adding the user context.
      class UserContext
        def initialize(app)
          @app = app
        end

        def call(env)
          @app.call(env)
        end

        private
          def user(env)
            if env['warden']
              env['warden'].user
            else
              nil
            end
          end
      end
    end
  end
end