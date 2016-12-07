require "singleton"

module Timber
  # Holds the current context in a thread safe memory storage. This context is
  # appended to every log line. Think of context as join data between your log lines,
  # allowing you to relate them and filter them appropriately.
  class CurrentContext
    include Singleton

    THREAD_NAMESPACE = :_timber_current_context.freeze

    class << self
      # Convenience method for {#with}.
      #
      # @example Adding a context
      #   custom_context = Timber::Contexts::Custom.new(type: :keyspace, data: %{my: "data"})
      #   Timber::CurrentContext.with(custom_context) do
      #     # ... anything logged here will have the context ...
      #   end
      def with(*args, &block)
        instance.with(*args, &block)
      end
    end

    # Adds a context to the current stack.
    def with(data)
      key = data.keyspace
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