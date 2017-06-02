require "timber/integrations/rack/middleware"

module Timber
  module Integrations
    module Rack
      # A Rack middleware that is responsible for adding the Session context
      # {Timber::Contexts::Session}.
      class SessionContext < Middleware
        def call(env)
          id = get_session_id(env)
          if id
            context = Contexts::Session.new(id: id)
            CurrentContext.with(context) do
              @app.call(env)
            end
          else
            @app.call(env)
          end
        end

        private
          def get_session_id(env)
            session = env['rack.session']

            if session
              begin
                if session.respond_to?(:id)
                  session.id
                elsif session.respond_to?(:[])
                  session["session_id"]
                end
              rescue Exception => e
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