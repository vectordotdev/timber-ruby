module Timber
  class CurrentContext
    THREAD_NAMESPACE = :_timber_context_stack.freeze

    include Patterns::DelegatedSingleton

    def add(context, &block)
      stack << context
      yield if block_given?
    ensure
      remove(context) if block_given?
    end

    def remove(context)
      stack.delete(context)
    end

    def to_hash
      {}.tap do |hash|
        stack.each do |context|
          hash[context.name] = context.to_hash
        end
      end
    end

    def to_json
      to_hash.to_json
    end

    private
      def stack
        # Ensure the stack is thread-safe
        Thread.current[THREAD_NAMESPACE] ||= []
      end
  end
end
