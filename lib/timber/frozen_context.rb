module Timber
  class FrozenContext
    attr_reader :stack

    def initialize(stack)
      @stack = stack.freeze
    end

    def json
      return @json if defined?(@json)
      # Build the json with string, it's better for performance.
      # It leverages the context.json cached string. It also
      # avoids creating an uneccessary hash.
      @json = "{"
      last_index = size - 1
      stack.each_with_index do |context, index|
        @json += "#{context.key_name.to_json}: #{context.json}"
        @json += ", " if index != last_index
      end
      @json += "}"
    end

    def size
      @stack.size
    end
  end
end
