require "timber/probes/action_controller_log_subscriber"
require "timber/probes/rack_http_context"

module Timber
  module Probes # :nodoc:
    def self.insert!(middleware, insert_before)
      ActionControllerLogSubscriber.insert!
      RackHTTPContext.insert!(middleware, insert_before)
    end
  end
end