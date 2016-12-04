module Timber
  # Holds the current context in the current thread's memory.
  # This context gets copied as each log line is written.
  class CurrentContext
    include Singleton

    THREAD_NAMESPACE = :_timber_current_context.freeze

    # Adds a context to the current stack.
    def with(key, data)
      hash[key] = data
      yield
    ensure
      hash.delete(key)
    end

    def snapshot
      hash.clone
    end

    private
      def hash
        Thread.current[THREAD_NAMESPACE] ||= {}
      end
  end
end