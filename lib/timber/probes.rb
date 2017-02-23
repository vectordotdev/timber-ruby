require "timber/probes/action_controller_log_subscriber"
require "timber/probes/action_controller_user_context"
require "timber/probes/action_dispatch_debug_exceptions"
require "timber/probes/action_view_log_subscriber"
require "timber/probes/active_record_log_subscriber"
require "timber/probes/active_support_tagged_logging"
require "timber/probes/rails_rack_logger"

module Timber
  # Namespace for all probes.
  # @private
  module Probes
    def self.insert!
      ActionControllerLogSubscriber.insert!
      ActionControllerUserContext.insert!
      ActionDispatchDebugExceptions.insert!
      ActionViewLogSubscriber.insert!
      ActiveRecordLogSubscriber.insert!
      ActiveSupportTaggedLogging.insert!
      RailsRackLogger.insert!
    end
  end
end