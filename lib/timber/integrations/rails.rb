require "timber/integration"
require "timber/integrations/rack/http_events"
require "timber/integrations/rails/rack_logger"

module Timber
  module Integrations
    # Module for holding *all* Rails integrations. This module does *not*
    # extend {Integration} because it's dependent on {Rack::HTTPEvents}. This
    # module simply disables the default HTTP request logging.
    module Rails
      def self.enabled?
        Rack::HTTPEvents.enabled?
      end

      def self.integrate!
        return false if !enabled?

        RackLogger.integrate!
      end
    end
  end
end