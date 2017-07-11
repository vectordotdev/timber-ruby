require "timber/integration"
require "timber/integrations/active_job/job_contet"

module Timber
  module Integrations
    # Module for holding *all* ActiveJob integrations. See {Integration} for
    # configuration details for all integrations.
    module ActiveJob
      extend Integration

      def self.integrate!
        return false if !enabled?

        JobContext.integrate!
      end
    end
  end
end