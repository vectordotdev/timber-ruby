begin
  require "rails"
rescue Exception
end

require "timber/config"
require "timber/contexts/session"
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
            if defined?(::Rails)
              session_key = ::Rails.application.config.session_options[:key]
              request = ::ActionDispatch::Request.new(env)
              Timber::Config.instance.debug { "Rails detected, extracting session_id from cookie" }
              extract_from_cookie(request, session_key)

            elsif session = env['rack.session']
              if session.respond_to?(:id)
                Timber::Config.instance.debug { "Rack env session detected, using id attribute" }
                session.id
              elsif session.respond_to?(:[])
                Timber::Config.instance.debug { "Rack env session detected, using the session_id key" }
                session["session_id"]
              else
                Timber::Config.instance.debug { "Rack env session detected but could not extract id" }
                nil
              end
            else
              Timber::Config.instance.debug { "No session data could be detected, skipping" }

              nil
            end
          rescue Exception => e
            nil
          end

          def extract_from_cookie(request, session_key)
            data = request
              .cookie_jar
              .signed_or_encrypted[session_key] || {}
            data["session_id"]
          end
      end
    end
  end
end