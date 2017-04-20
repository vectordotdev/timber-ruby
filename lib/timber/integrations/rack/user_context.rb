module Timber
  module Integrations
    module Rack
      # Reponsible for adding the user context.
      class UserContext
        def initialize(app)
          @app = app
        end

        def call(env)
          debug { "#{self.class.name} - Starting user context" }
          user_hash = get_user_hash(env)
          if user_hash
            debug { "#{self.class.name} - User hash found: #{user_hash.inspect}" }
            context = Contexts::User.new(user_hash)
            CurrentContext.with(context) do
              @app.call(env)
            end
          else
            debug { "#{self.class.name} - User hash not found" }
            @app.call(env)
          end
        end

        private
          def get_user_hash(env)
            get_omniauth_user_hash(env) ||
              get_warden_user_hash(env) ||
              nil
          end

          def get_omniauth_user_hash(env)
            if env['omniauth.auth']
              debug { "#{self.class.name} - Omniauth hash present #{env['omniauth.auth'].inspect}" }
              auth_hash = env['omniauth.auth']
              info = auth_hash['info']

              {
                id: auth_hash['uid'],
                name: info['name'],
                email: info['email']
              }
            else
              debug { "#{self.class.name} - Omniauth hash not present" }
              nil
            end
          end

          def get_warden_user_hash(env)
            if env['warden']
              debug { "#{self.class.name} - Warden object present #{env['warden'].inspect}" }
              user = env['warden'].user
              debug { "#{self.class.name} - Warden user object #{env['warden'].user.inspect}" }
              id = try_user_id(user)
              name = try_user_name(user)
              email = try_user_email(user)

              if id || name || email
                debug { "#{self.class.name} - At least one warden user attribute was present" }
                {id: id, name: name, email: email}
              else
                debug { "#{self.class.name} - No warden user attributes were present" }
                nil
              end
            else
              nil
            end
          end

          def try_user_id(user)
            user.respond_to?(:id) ? user.id : nil
          end

          def try_user_name(user)
            if user.respond_to?(:name) && user.name.is_a?(String)
              user.name
            elsif user.respond_to?(:first_name) && user.first_name.is_a?(String) && user.respond_to?(:last_name) && user.last_name.is_a?(String)
              "#{user.first_name} #{user.last_name}"
            else
              nil
            end
          end

          def try_user_email(user)
            if user.respond_to?(:email) && user.email.is_a?(String)
              user.email
            else
              nil
            end
          end

          def debug_logger
            Timber::Config.instance.debug_logger
          end

          def debug(&block)
            if debug_logger
              message = yield
              debug_logger.debug(message)
            end
          end
      end
    end
  end
end