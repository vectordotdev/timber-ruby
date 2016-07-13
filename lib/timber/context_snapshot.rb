module Timber
  class ContextSnapshot
    attr_reader :indexes, :stack

    def initialize
      @stack = CurrentContext.stack.clone.freeze
      @indexes = CurrentLineIndexes.indexes.clone.freeze
    end

    def to_json
      return @json if defined?(@json)
      # Build the json with string, it's better for performance.
      # It leverages the context.to_json cached string. It also
      # avoids creating an uneccessary hash.
      @json = "{"
      @json += "\"indexes\": #{indexes_hash.to_json}, "
      @json += "\"hierarchy\": #{hierarchy.to_json}, "
      @json += "\"data\": {"
      last_index = size - 1
      stack.each_with_index do |context, index|
        @json += "#{context.key_name.to_json}: #{context.to_json}"
        @json += ", " if index != last_index
      end
      @json += "}}"
    end

    def hierarchy
      @hierarchy ||= stack.collect(&:key_name)
    end

    def size
      stack.size
    end

    private
      def indexes_hash
        @indexes_hash ||= {}.tap do |hash|
          indexes.each do |context, index|
            hash[context.key_name] = index
          end
        end
      end
  end
end
