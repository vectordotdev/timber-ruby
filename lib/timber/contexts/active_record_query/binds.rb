module Timber
  module Contexts
    class ActiveRecordQuery < Context
      class Binds < DynamicValues
        attr_reader :log_subscriber, :binds

        def initialize(log_subscriber, binds)
          # Initialize should be as fast as possible since it is executed inline.
          # Hence the lazy methods below.
          @log_subscriber = log_subscriber
          @binds = binds
          super()
        end

        private
          # Override values_array so that this is done in the background thread
          def values_array
            @values_array ||= binds.collect do |bind|
              name, value = render_bind(bind)
              {:name => name, :value => value}
            end
          end

          def render_bind(bind)
            if bind.is_a?(Array)
              # AR 4.2.X
              log_subscriber.render_bind(*bind)
            else
              log_subscriber.render_bind(bind)
            end
          end
      end
    end
  end
end
