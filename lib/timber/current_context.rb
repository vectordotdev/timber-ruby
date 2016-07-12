module Timber
  # Holds the current context in the current thread's memory.
  # This context gets copied as each log line is written.
  class CurrentContext
    THREAD_NAMESPACE = :_timber_context_stack.freeze

    include Patterns::DelegatedSingleton

    def add(*contexts, &block)
      stack.push(*(contexts.compact))
      clear_cache # Ensure we clear the cacke when the stack changes
      yield if block_given?
      self
    ensure
      remove(*contexts) if block_given?
    end

    # Used to efficiently clone the context. Cached to avoid
    # uneccessary cloning if the context has not changed
    def frozen_clone
      # Cloning the array is efficient and will point to the same objects.
      @frozen_clone ||= Timber::FrozenContext.new(stack.clone)
    end

    def remove(*contexts)
      # Ensure we clear the cacke when the stack changes
      contexts.each do |context|
        stack.delete(context)
      end
      clear_cache
      self
    end

    private
      def clear_cache
        remove_instance_variable(:@frozen_clone) if instance_variable_defined?(:@frozen_clone)
      end

      def stack
        Thread.current[THREAD_NAMESPACE] ||= []
      end
  end
end
