require "timber/integrations/rack/exception_event"
require "timber/integrations/rack/http_context"
require "timber/integrations/rack/http_events"
require "timber/integrations/rack/session_context"
require "timber/integrations/rack/user_context"

module Timber
  module Integrations
    module Rack
      # Enable / disable all Rack middlewares with a single setting.
      def self.enabled=(value)
        ExceptionEvent.enabled = value
        HTTPContext.enabled = value
        HTTPEvents.enabled = value
        SessionContext.enabled = value
        UserContext.enabled = value
      end

      # All enabled middlewares. The order is relevant. Middlewares that set
      # context are added first so that context is included in subsequent log lines.
      def self.middlewares
        @middlewares ||= [HTTPContext, SessionContext, UserContext,
          HTTPEvents, ExceptionEvent].select(&:enabled?)
      end
    end
  end
end