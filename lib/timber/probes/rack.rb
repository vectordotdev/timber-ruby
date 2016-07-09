module Timber
  module Probes
    class Rack < Probe
      class Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          context = Contexts::Rack.new(env)
          CurrentContext.add(context) do
            @app.call(env)
          end
        end
      end

      attr_reader :middleware, :insert_before

      def initialize(middleware, insert_before)
        if middleware.nil?
          raise RequirementNotMetError.new("The middleware class attribute is not set. " +
            "We need a middleware to insert the probe.")
        end
        @middleware = middleware
        @insert_before = insert_before
      end

      def insert!
        # Ensures
        middleware.insert_before insert_before, Middleware
      end
    end
  end
end
