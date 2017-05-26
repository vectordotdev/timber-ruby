require "timber/integrations/rack/middleware"

module Timber
  module Integrations
    module Rack
      # Reponsible for capturing exceptions events within a Rack stack.
      class ExceptionEvent < Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          begin
            status, headers, body = @app.call(env)
          rescue Exception => exception
            Config.instance.logger.fatal do
              Events::Exception.new(
                name: exception.class.name,
                exception_message: exception.message,
                backtrace: exception.backtrace
              )
            end

            raise exception
          end
        end
      end
    end
  end
end