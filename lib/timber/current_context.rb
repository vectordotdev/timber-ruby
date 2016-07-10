module Timber
  # Holds the current context in the current thread's memory.
  # This context gets copied as each log line is written.
  class CurrentContext
    THREAD_NAMESPACE = :_timber_context_stack.freeze

    include Patterns::DelegatedSingleton

    def initialize(stack = nil)
      @stack = stack
    end

    def add(context, &block)
      # Ensure we clear the cacke when the stack changes
      (stack << context).tap { clear_cache }
      yield if block_given?
      #
    ensure
      remove(context) if block_given?
    end

    # Used to efficiently clone the context.
    def clone
      # Cloning the array is efficient and will point to the same objects.
      self.class.new(stack.clone)
    end

    def remove(context)
      # Ensure we clear the cacke when the stack changes
      stack.delete(context).tap { clear_cache }
    end

    def json
      return @json if defined?(@json)
      # Build the json with string, it's better for performance.
      # It leverages the context.json cached string.
      @json = "{"
      last_index = size - 1
      stack.each_with_index do |context, index|
        @json += "#{context.key_name.to_json}: #{context.json}"
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
        @stack || (Thread.current[THREAD_NAMESPACE] ||= [])
      end
  end
end
