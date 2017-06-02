require "timber/integrator"

module Timber
  module Integrations
    module ActionView
      # Reponsible for uninstalling the default `ActionView::LogSubscriber` and installing
      # the TimberLogSubscriber.
      #
      # @private
      class LogSubscriber < Integrator
        def initialize
          require "action_view/log_subscriber"
          require "timber/integrations/action_view/log_subscriber/timber_log_subscriber"
        rescue LoadError => e
          raise RequirementNotMetError.new(e.message)
        end

        def integrate!
          return true if Util::ActiveSupportLogSubscriber.subscribed?(:action_view, TimberLogSubscriber)

          Util::ActiveSupportLogSubscriber.unsubscribe!(:action_view, ::ActionView::LogSubscriber)
          TimberLogSubscriber.attach_to(:action_view)
        end
      end
    end
  end
end