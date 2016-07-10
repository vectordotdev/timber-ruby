module Timber
  # Holds the current context in the current thread's memory.
  # This context gets copied as each log line is written.
  class CurrentContext
    THREAD_NAMESPACE = :_timber_context_stack.freeze

    include Patterns::DelegatedSingleton

    def add(context, &block)
      # Ensure we clear the cacke when the stack changes
      (stack << context).tap { clear_cache }
      yield if block_given?
      #
    ensure
      remove(context) if block_given?
    end

    # Used to efficiently clone the context. Cached to avoid
    # uneccessary cloning if the context has not changed
    def frozen_clone
      # Cloning the array is efficient and will point to the same objects.
      @frozen_clone ||= Timber::FrozenContext.new(stack.clone)
    end

    def remove(context)
      # Ensure we clear the cacke when the stack changes
      stack.delete(context).tap { clear_cache }
    end

    private
      def clear_cache
        remove_instance_variable(:@frozen_clone) if instance_variable_defined?(:@frozen_clone)
      end

      def size
        stack.size
      end

      def stack
        (Thread.current[THREAD_NAMESPACE] ||= [])
      end
  end
end
