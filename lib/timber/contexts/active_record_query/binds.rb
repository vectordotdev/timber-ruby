module Timber
  module Contexts
    class ActiveRecordQuery < Context
      class Binds < DynamicValues
        attr_reader :binds
        
        def initialize(binds)
          @binds = binds
          super()
        end

        private
          def values_array
            @values_array ||= binds.collect do |bind|
              {:name => bind.attribute_name, :value => bind_value(bind)}
            end
          end

          def bind_value(bind)
            if bind.type.binary? && bind.value
              "<#{attribute.value.bytesize} bytes of binary data>"
            else
              bind.value_for_database
            end
          end
      end
    end
  end
end
