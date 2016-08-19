module Timber
  module Contexts
    module HTTPRequests
      class Rack < HTTPRequest
        class Params < DynamicValues
          attr_reader :params

          def initialize(params)
            # Initialize should be as fast as possible since it is executed inline.
            # Hence the lazy methods below.
            @params = params
            super()
          end

          private
            # Override values_array so that this is done in the background thread
            def values_array
              @values_array ||= params.collect do |key, value|
                {:name => key, :value => value}
              end
            end
        end
      end
    end
  end
end
