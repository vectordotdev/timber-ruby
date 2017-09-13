require "timber/config"
require "timber/contexts/user"
require "timber/integrations/rack/middleware"

module Timber
  module Integrations
    module Rack
      # This is a Rack middleware responsible for setting the user context.
      # See {Timber::Contexts::User} for more information on the user context.
      #
      # ## Why a Rack middleware?
      #
      # We use a Rack middleware because we want to set the user context as early as
      # possible, and before the initial incoming request log line:
      #
      #   Started GET /welcome
      #
      # The above log line is logged in a request middleware, before it reaches
      # the controller.
      #
      # If, for example, we set the user context in a controller, the log line above
      # will not have the user context attached. This is because it is logged before
      # the controller is executed. This is not ideal, and it's why we take a middleware
      # approach here. If for some reason you cannot identify the user at the middleware
      # level then setting it in the controller is perfectly fine, just be aware of the
      # above downside.
      #
      # ## Authentication frameworks automatically detected:
      #
      # If you use any of the following authentication frameworks, Timber will
      # automatically set the user context for you.
      #
      # * Devise, or any Warden based authentication strategy
      # * Clearance
      #
      # Or, you can use your own custom authentication, see the {.custom_user_context}
      # class method for more details.
      #
      # @note This middleware is automatically inserted for frameworks we support.
      #   Such as Rails. See {Timber::Frameworks} for a comprehensive list.
      class UserContext < Middleware
        class << self
          # The custom user context allows you to hook in and set your own custom
          # user context. This is used in situations where either:
          #
          # 1. Timber does not automatically support your authentication strategy (see module level docs)
          # 2. You need to customize your authentication beyond Timber's defaults.
          #
          # @example Setting your own custom user context
          #   Timber::Integrations::Rack::UserContext.custom_user_hash = lambda do |rack_env|
          #     rack_env['my_custom_key'].user
          #   end
          def custom_user_hash=(proc)
            if proc && !proc.is_a?(Proc)
              raise ArgumentError.new("The value passed to #custom_user_hash must be a Proc")
            end

            @custom_user_hash = proc
          end

          # Accessor method for {#custom_user_hash=}.
          def custom_user_hash
            @custom_user_hash
          end
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
            # The order is relevant here. The 'warden' key can be set, but
            # not return a user, in which case the user data might be in another key.
            if self.class.custom_user_hash.is_a?(Proc)
              Timber::Config.instance.debug { "Obtaining user context from the custom user hash" }
              self.class.custom_user_hash.call(env)
            elsif env[:clearance] && env[:clearance].signed_in?
              Timber::Config.instance.debug { "Obtaining user context from the clearance user" }
              user = env[:clearance].current_user
              get_user_object_hash(user)
            elsif env['warden'] && (user = env['warden'].user)
              Timber::Config.instance.debug { "Obtaining user context from the warden user" }
              get_user_object_hash(user)
            else
              Timber::Config.instance.debug { "Could not locate any user data" }
              nil
            end
          end

          def get_user_object_hash(user)
            id = try_user_id(user)
            name = try_user_name(user)
            email = try_user_email(user)

            if id || name || email
              {id: id, name: name, email: email}
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
      end
    end
  end
end