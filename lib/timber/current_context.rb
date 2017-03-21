require "singleton"

module Timber
  # Holds the current context in a thread safe memory storage. This context is
  # appended to every log line. Think of context as join data between your log lines,
  # allowing you to relate them and filter them appropriately.
  #
  # @note Because context is appended to every log line, it is recommended that you limit this
  #   to only neccessary data needed to relate your log lines.
  class CurrentContext
    include Singleton

    THREAD_NAMESPACE = :_timber_current_context.freeze

    class << self
      # Convenience method for {#with}. See {#with} for full details and examples.
      def with(*args, &block)
        instance.with(*args, &block)
      end

      # Convenience method for {#add}. See {#add} for full details and examples.
      def add(*args)
        instance.add(*args)
      end

      def hash(*args)
        instance.hash(*args)
      end

      # Convenience method for {#remove}. See {#remove} for full details and examples.
      def remove(*args)
        instance.remove(*args)
      end

      def reset(*args)
        instance.reset(*args)
      end
    end

    # Adds a context and then removes it when the block is finished executing.
    #
    # @note Because context is included with every log line, it is recommended that you limit this
    #   to only neccessary data.
    #
    # @example Adding a custom context with a map
    #   Timber::CurrentContext.with({build: {version: "1.0.0"}}) do
    #     # ... anything logged here will include the context ...
    #   end
    #
    # @example Adding a custom context with a struct
    #   BuildContext = Struct.new(:version) do
    #     def type; :build; end
    #    end
    #    build_context = BuildContext.new("1.0.0")
    #    Timber::CurrentContext.with(build_context) do
    #     # ... anything logged here will include the context ...
    #   end
    #   # Be sure to checkout Timber::Contexts! These are officially supported and many of these
    #   # will be automatically included via Timber::Integrations
    #
    # @example Adding multiple contexts
    #   Timber::CurrentContext.with(context1, context2) { ... }
    def with(*objects)
      add(*objects)
      yield
    ensure
      remove(*objects)
    end

    # Adds contexts but does not remove them. See {#with} for automatic maintenance and {#remove}
    # to remove them yourself.
    #
    # @note Because context is included with every log line, it is recommended that you limit this
    #   to only neccessary data.
    def add(*objects)
      objects.each do |object|
        context = Contexts.build(object) # Normalizes objects into a Timber::Context descendant.
        key = context.keyspace
        json = context.as_json # Convert to json now so that we aren't doing it for every line
        if key == :custom
          # Custom contexts are merged into the space
          hash[key] ||= {}
          hash[key].merge!(json)
        else
          hash[key] = json
        end
      end
    end

    # The internal hash that is maintained. It is recommended that you use {#with} and {#add}
    # for hash maintenance.
    def hash
      Thread.current[THREAD_NAMESPACE] ||= {}
    end

    # Removes a context. If you wish to remove by key, or some other way, use {#hash} and
    # modify the hash accordingly.
    def remove(*objects)
      objects.each do |object|
        if object.is_a?(Symbol)
          hash.delete(object)
        else
          context = Contexts.build(object)

          if context.keyspace == :custom
            # Custom contexts are merged and should be removed the same
            hash[context.keyspace].delete(context.type)
            if hash[context.keyspace] == {}
              hash.delete(context.keyspace)
            end
          else
            hash.delete(context.keyspace)
          end
        end
      end
    end

    # Resets the context to be blank. Use this carefully! This will remove *any* context,
    # include context that is automatically included with Timber.
    def reset
      hash.clear
    end

    # Snapshots the current context so that you get a moment in time representation of the context,
    # since the context can change as execution proceeds.
    def snapshot
      hash.clone
    end
  end
end
