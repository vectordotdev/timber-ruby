require "timber/integrations/action_controller/log_subscriber"
require "timber/integrations/action_dispatch/debug_exceptions"
require "timber/integrations/action_view/log_subscriber"
require "timber/integrations/active_record/log_subscriber"
require "timber/integrations/active_support/tagged_logging"
require "timber/integrations/rack"
require "timber/integrations/rails/rack_logger"

module Timber
  # Namespace for all integrations.
  # @private
  module Integrations
    def self.integrate!
      ActionController::LogSubscriber.integrate!
      ActionDispatch::DebugExceptions.integrate!
      ActionView::LogSubscriber.integrate!
      ActiveRecord::LogSubscriber.integrate!
      ActiveSupport::TaggedLogging.integrate!
      Rails::RackLogger.integrate!
    end
  end
end