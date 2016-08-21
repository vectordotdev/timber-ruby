module Timber
  module Patterns
    # Module to fall inline with Rail's craziness changing default object behavior.
    # If Rails is present, it will play nice. If not, it will work just fine.
    module ToJSON
      def as_json(*args)
        @as_json ||= {}
        @as_json[args] ||= begin
          hash = json_payload # only call the function once incase it is not cached
          hash = hash.respond_to?(:as_json) ? hash.as_json(*args) : hash
          hash.reject { |k,v| v.nil? || v == [] }
        end
      end

      def to_json(*args)
        @to_json ||= {}
        @to_json[args] ||= as_json(*args).to_json
      end

      private
        def json_payload
          raise NotImplementedError.new("#json_payload is not implemented for #{self.class}")
        end
    end
  end
end