module Timber
  # Holds the current context in the current thread's memory.
  # This context gets copied as each log line is written.
  class CurrentContext
    THREAD_NAMESPACE = :_timber_current_context.freeze
    STACK_KEYNAME = :stack.freeze
    SNAPSHOT_KEYNAME = :snapshot.freeze

    include Patterns::DelegatedSingleton

    def add(*contexts, &block)
      contexts.compact.each do |context|
        CurrentLineIndexes.context_added(context)
        stack << context
      end
      clear_cache # Ensure we clear the cacke when the stack changes
      if block_given?
        yield
      else
        self
      end
    ensure
      remove(*contexts) if block_given?
    end

    # Used to efficiently clone the context. Cached to avoid
    # uneccessary cloning if the context has not changed
    def snapshot
      # Cloning the array is efficient and will point to the same objects.
      storage[SNAPSHOT_KEYNAME] ||= Timber::ContextSnapshot.new
    end

    def remove(*contexts)
      # Ensure we clear the cacke when the stack changes
      contexts.each do |context|
        CurrentLineIndexes.context_removed(context)
        stack.delete(context)
      end
      clear_cache
      self
    end

    def stack
      storage[STACK_KEYNAME] ||= []
    end

    private
      def clear_cache
        storage.delete(SNAPSHOT_KEYNAME)
      end

      def storage
        Thread.current[THREAD_NAMESPACE] ||= {}
      end
  end
end
