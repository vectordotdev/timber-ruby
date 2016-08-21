module Timber
  module Patterns
    # Module to fall inline with Rail's core object crazy changes.
    # If Rails is present, it will play nice. If not, it will work just fine.
    module ToJSON
      # We explicitly do not do anything with the arguments as we do not need them.
      # We avoid the unneccssary complexity.
      def as_json(*args)
        @as_json ||= Macros::Compactor.compact(json_payload)
      end

      def to_json(*args)
        @to_json ||= as_json.to_json
      end

      private
        def json_payload
          raise NotImplementedError.new("#json_payload is not implemented for #{self.class}")
        end
    end
  end
end