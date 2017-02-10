require "timber/rack_middlewares/http_context"

module Timber
  # Namespace for all Rack middlewares.
  module RackMiddlewares
    # A list containing *all* `Timber::RackMiddlewares::*` sub classes. This makes it easy to
    # achieve forward compatibility as middlewares are modified.
    def self.middlewares
      @middlewares ||= [HTTPContext]
    end
  end
end
