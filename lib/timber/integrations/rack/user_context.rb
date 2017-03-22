module Timber
  module Integrations
    module Rack
      # Reponsible for adding the user context.
      class UserContext
        def initialize(app)
          @app = app
        end

        def call(env)
          user_hash = get_user_hash(env)
          if user_hash
            context = Contexts::User.new(user_hash)
            CurrentContext.with(context) do
              @app.call(env)
            end
          else
            @app.call(env)
          end
        end

        private
          def get_user_hash(env)
            if env['warden']
              get_user_hash_from_object(env['warden'].user)
            elsif env['omniauth.auth']
              auth_hash = env['omniauth.auth']
              info = auth_hash['info']

              {
                id: auth_hash['uid'],
                name: info['name'],
                email: info['email']
              }
            else
              nil
            end
          end

          def get_user_hash_from_object(user)
            {
              id: user_id(user),
              name: user_name(user),
              email: user_email(user)
            }
          end

          def user_id(user)
            user.respond_to?(:id) ? user.id : nil
          end

          def user_name(user)
            if user.respond_to?(:name) && user.name.is_a?(String)
              user.name
            elsif user.respond_to?(:first_name) && user.first_name.is_a?(String) && user.respond_to?(:last_name) && user.last_name.is_a?(String)
              "#{user.first_name} #{user.last_name}"
            else
              nil
            end
          end

          def user_email(user)
            if user.respond_to?(:email) && user.email.is_a?(String)
              user.email
            else
              nil
            end
          end
      end
    end
  end
end