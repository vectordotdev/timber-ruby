require "timber/probes/rack_http_context"

module Timber
  module Probes
    def self.insert!(middleware, insert_before)
      RackHTTPContext.insert!
    end
  end
end