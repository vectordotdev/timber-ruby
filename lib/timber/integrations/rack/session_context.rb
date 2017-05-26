require "timber/integrations/rack/middleware"

module Timber
  module Integrations
    module Rack
      # Reponsible for adding the Session context for applications that use `Rack`.
      class SessionContext < Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          id = get_session_id(env)
          if id
            context = Contexts::Session.new(id: get_session_id(env))
            CurrentContext.with(context) do
              @app.call(env)
            end
          else
            @app.call(env)
          end
        end

        private
          def get_session_id(env)
            if env['rack.session']
              begin
                env['rack.session'].id
              rescue Exception
                nil
              end
            else
              nil
            end
          end
      end
    end
  end
end