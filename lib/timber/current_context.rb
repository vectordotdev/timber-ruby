module Timber
  class CurrentContext
    THREAD_NAMESPACE = :_timber_context_stack

    extend self

    def add(context, &block)
      stack << context
    end

    def remove(context)
      stack.remove(context)
    end

    def to_json

    end

    def wrap(context, &block)
      add(context)
      yield
    ensure
      remove(context)
    end

    private
      def stack
        # Ensure the stack is thread-safe
        Thread.current[THREAD_NAMESPACE] ||= []
      end
  end
end
