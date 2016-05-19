require "singleton"

module Timber
  class CurrentContext
    THREAD_NAMESPACE = :_timber_context_stack

    include Singleton

    class << self
      def add(*args, &block)
        instance.add(*args, &block)
      end
    end

    def add(context, &block)
      stack << context
      yield if block_given?
    ensure
      remove(context) if block_given?
    end

    def remove(context)
      stack.delete(context)
    end

    def to_json

    end

    private
      def stack
        # Ensure the stack is thread-safe
        Thread.current[THREAD_NAMESPACE] ||= []
      end
  end
end
