require "set"

module Timber
  # Holds the current context in the current thread's memory.
  # This context gets copied as each log line is written.
  class CurrentContext
    THREAD_NAMESPACE = :_timber_current_context.freeze
    STACK_KEYNAME = :stack.freeze
    PRECISION = 8.freeze

    include Patterns::DelegatedSingleton

    # Adds a context to the current stack.
    def add(*contexts, &_block)
      contexts = contexts.compact
      contexts.each do |context|
        stack << context
      end
      puts "Adding: #{caller.inspect}"
      block_given? ? yield : self
    ensure
      remove(*contexts) if block_given?
    end

    # Get a specific context type off the stack
    def get(type)
      stack.find { |context| context.is_a?(type) }
    end

    # Removes the contexts from the current stack.
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

    def valid_stack
      stack.select(&:valid?)
    end

    private
      def stack
        storage[STACK_KEYNAME] ||= []
      end

      def storage
        Thread.current[THREAD_NAMESPACE] ||= {}
      end
  end
end
