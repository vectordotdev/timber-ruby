require "timber/integration"
require "timber/integrations/rails/rack_logger"

module Timber
  module Integrations
    # Module for holding *all* Rails integrations. See {Integration} for
    # configuration details for all integrations.
    module Rails
      extend Integration

      def self.integrate!
        RackLogger.integrate!
      end
    end
  end
end