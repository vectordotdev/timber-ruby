module Timber
  module Probes
    # Responsible for automatically tracking controller call and http response events
    # for applications that use `ActionController`.
    class ActionControllerUserContext < Probe
      module AroundFilter
        def self.included(klass)
          klass.class_eval do
            if klass.respond_to?(:around_action)
              around_action :_timber_capture_user_context
            else
              around_filter :_timber_capture_user_context
            end

            private
              def _timber_capture_user_context
                user_method_name = Config.instance.current_user_method_name

                if respond_to?(user_method_name, true)
                  user_obj = send(user_method_name)

                  id = Timber::Util::Object.try(user_obj, :id)
                  name = Timber::Util::Object.try(user_obj, :name)

                  if !name
                    first_name = Timber::Util::Object.try(user_obj, :first_name)
                    last_name = Timber::Util::Object.try(user_obj, :last_name)
                    if first_name || last_name
                      name = [first_name, last_name].compact.join(" ")
                    end
                  end

                  email = Timber::Util::Object.try(user_obj, :email)

                  user_context = Timber::Contexts::User.new(:id => id, :name => name, :email => email)

                  Timber::CurrentContext.with(user_context) do
                    yield
                  end

                else
                  yield
                end
              end
          end
        end
      end

      def initialize
        require "action_controller"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if ActionController::Base.include?(AroundFilter)
        ActionController::Base.send(:include, AroundFilter)
      end
    end
  end
end