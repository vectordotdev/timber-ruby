module Timber
  # Holds the current context in the current thread's memory.
  # This context gets copied as each log line is written.
  class CurrentContext
    THREAD_NAMESPACE = :_timber_current_context.freeze
    STACK_KEYNAME = :stack.freeze

    include Patterns::DelegatedSingleton

    def add(*contexts, &block)
      contexts = contexts.compact
      contexts.each do |context|
        CurrentLineIndexes.context_added(context)
        stack << context
      end
      if block_given?
        yield
      else
        self
      end
    ensure
      remove(*contexts) if block_given?
    end

    def stack
      @stack
    end
    
    def includes?(context_class)
      stack.any? { |context| context.is_a?(context_class) }
    end

    def remove(*contexts)
      # Ensure we clear the cacke when the stack changes
      contexts.each do |context|
        CurrentLineIndexes.context_removed(context)
        stack.delete(context)
      end
      self
    end

    # Used to efficiently clone the context
    def snapshot
      # Cloning the array is efficient and will point to the same objects.
      Timber::ContextSnapshot.new
    end

    def stack
      storage[STACK_KEYNAME] ||= []
    end

    private
      def storage
        Thread.current[THREAD_NAMESPACE] ||= {}
      end
  end
end
