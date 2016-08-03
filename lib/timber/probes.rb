require "timber/probes/action_controller_base"
require "timber/probes/action_dispatch_debug_exceptions"
require "timber/probes/active_support_log_subscriber"
require "timber/probes/heroku"
require "timber/probes/logger"
require "timber/probes/rack"

module Timber
  module Probes
    def self.insert!(middleware, insert_before)
      ActionControllerBase.insert!
      ActionDispatchDebugExceptions.insert!
      ActiveSupportLogSubscriber.insert!
      Heroku.insert!
      Logger.insert!
      Rack.insert!(middleware, insert_before)
    end
  end
end
