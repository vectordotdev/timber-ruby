require "timber/integrations/rack/exception_event"
require "timber/integrations/rack/http_context"
require "timber/integrations/rack/http_events"
require "timber/integrations/rack/session_context"
require "timber/integrations/rack/user_context"

module Timber
  module Integrations
    module Rack
      # All enabled middlewares. The order is relevant. Middlewares that set
      # context are added first so that context is included in subsequent log lines.
      def self.enabled_middlewares
        @middlewares ||= [HTTPContext, SessionContext, UserContext,
          HTTPEvents, ExceptionEvent].select(&:enabled?)
      end
    end
  end
end