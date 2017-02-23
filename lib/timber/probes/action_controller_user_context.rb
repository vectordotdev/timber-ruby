module Timber
  module Probes
    # Responsible for automatically tracking controller call and http response events
    # for applications that use `ActionController`.
    class ActionControllerUserContext < Probe
      module AroundFilter
        def self.included(klass)
          klass.class_eval do
            around_filter :_timber_capture_user_context

            private
              def _timber_capture_user_context
                if respond_to?(:current_user, true)
                  id = Timber::Util::Object.try(current_user, :id)
                  name = Timber::Util::Object.try(current_user, :name)
                  if !name
                    first_name = Timber::Util::Object.try(current_user, :first_name)
                    last_name = Timber::Util::Object.try(current_user, :last_name)
                    if first_name || last_name
                      name = [first_name, last_name].compact.join(" ")
                    end
                  end
                  email = Timber::Util::Object.try(current_user, :email)
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