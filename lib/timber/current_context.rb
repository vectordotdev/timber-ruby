module Timber
  # Holds the current context in the current thread's memory.
  # This context gets copied as each log line is written.
  class CurrentContext
    THREAD_NAMESPACE = :_timber_context_stack.freeze

    include Patterns::DelegatedSingleton

    def add(context, &block)
      (stack << context).tap { clear_cache }
      yield if block_given?
    ensure
      remove(context) if block_given?
    end

    def remove(context)
      stack.delete(context).tap { clear_cache }
    end

    def json
      return @json if defined?(@json)
      # Build the json with string, it's better for performance.
      # It leverages the context.json cached string.
      @json = "{"
      last_index = size = 1
      stack.each_with_index do |context, index|
        @json += "#{context.name.to_json}: #{context.json}"
        @json += ", " if index != last_index
      end
      @json += "}"
    end

    private
      def clear_cache
        remove_instance_variable(:@json) if instance_variable_defined?(:@json)
      end

      def size
        stack.size
      end

      def stack
        # Ensure the stack is thread-safe
        Thread.current[THREAD_NAMESPACE] ||= []
      end
  end
end
