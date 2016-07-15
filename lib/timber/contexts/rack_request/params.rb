module Timber
  module Contexts
    class RackRequest < HTTPRequest
      class Params < DynamicValues
        attr_reader :params

        def initialize(params)
          @params = params
          super()
        end

        private
          def values_array
            @values_array ||= params.collect do |key, value|
              {:name => key, :value => value}
            end
          end
      end
    end
  end
end
