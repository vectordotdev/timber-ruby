module Timber
  module Probes
    class Rack < Probe
      class Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          context = Contexts::RackRequest.new(env)
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
        return true if middleware.instance_variable_get(:"@_timber_inserted") == true
        # Fucking rails uses a proxy
        middleware.instance_variable_set(:"@_timber_inserted", true)
        middleware.insert_before insert_before, Middleware
      end
    end
  end
end
