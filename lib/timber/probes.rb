require "timber/probes/action_controller_log_subscriber"
require "timber/probes/action_dispatch_debug_exceptions"
require "timber/probes/action_view_log_subscriber"
require "timber/probes/active_record_log_subscriber"
require "timber/probes/active_support_tagged_logging"
require "timber/probes/rack_http_context"
require "timber/probes/rails_rack_logger"

module Timber
  # Namespace for all probes.
  # @private
  module Probes
    def self.insert!(middleware, insert_before)
      ActionControllerLogSubscriber.insert!
      ActionDispatchDebugExceptions.insert!
      ActionViewLogSubscriber.insert!
      ActiveRecordLogSubscriber.insert!
      ActiveSupportTaggedLogging.insert!
      RackHTTPContext.insert!(middleware, insert_before)
      RailsRackLogger.insert!
    end
  end
end