require "socket"

require "timber/config"
require "timber/contexts/release"
require "timber/contexts/system"

module Timber
  # Holds the current context in a thread safe memory storage. This context is
  # appended to every log line. Think of context as join data between your log lines,
  # allowing you to relate them and filter them appropriately.
  #
  # @note Because context is appended to every log line, it is recommended that you limit this
  #   to only neccessary data needed to relate your log lines.
  class CurrentContext
    THREAD_NAMESPACE = :_timber_current_context.freeze

    class << self
      # Impelements the Singleton pattern in a thread specific way. Each thread receives
      # its own context.
      def instance
        Thread.current[THREAD_NAMESPACE] ||= new
      end

      # Convenience method for {CurrentContext#with}. See {CurrentContext#with} for more info.
      def with(*args, &block)
        instance.with(*args, &block)
      end

      # Convenience method for {CurrentContext#add}. See {CurrentContext#add} for more info.
      def add(*args)
        instance.add(*args)
      end

      # Convenience method for {CurrentContext#fetch}. See {CurrentContext#fetch} for more info.
      def fetch(*args)
        instance.fetch(*args)
      end

      # Convenience method for {CurrentContext#remove}. See {CurrentContext#remove} for more info.
      def remove(*args)
        instance.remove(*args)
      end

      # Convenience method for {CurrentContext#reset}. See {CurrentContext#reset} for more info.
      def reset(*args)
        instance.reset(*args)
      end
    end

    # Adds a context and then removes it when the block is finished executing.
    #
    # @note Because context is included with every log line, it is recommended that you limit this
    #   to only neccessary data.
    #
    # @example Adding a custom context
    #   Timber::CurrentContext.with({build: {version: "1.0.0"}}) do
    #     # ... anything logged here will include the context ...
    #   end
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
        add_to!(hash, object)
      end
      expire_cache!
      self
    end

    # Fetch a specific context by key.
    def fetch(*args)
      hash.fetch(*args)
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
      expire_cache!
      self
    end

    # Resets the context to be blank. Use this carefully! This will remove *any* context,
    # include context that is automatically included with Timber.
    def reset
      hash.clear
      expire_cache!
      self
    end

    # Snapshots the current context so that you get a moment in time representation of the context,
    # since the context can change as execution proceeds. Note that individual contexts
    # should be immutable, and we implement snapshot caching as a result of this assumption.
    def snapshot
      @snapshot ||= begin
        snapshot = hash.clone
        if snapshot.key?(:custom)
          snapshot[:custom] = hash[:custom].clone
        end
        snapshot
      end
    end

    private
      # The internal hash that is maintained. Use {#with} and {#add} for hash maintenance.
      def hash
        @hash ||= build_initial_hash
      end

      # Builds the initial hash. This is extract into a method to support a threaded
      # environment. Each thread holds it's own context and also needs to instantiate
      # it's hash properly.
      def build_initial_hash
        new_hash = {}

        # Release context
        release_context = Contexts::Release.from_env
        if release_context
          add_to!(new_hash, release_context)
        end

        # System context
        hostname = Socket.gethostname
        pid = Process.pid
        system_context = Contexts::System.new(hostname: hostname, pid: pid)
        add_to!(new_hash, system_context)

        # Runtime context
        thread_object_id = Thread.current.object_id
        runtime_context = Contexts::Runtime.new(vm_pid: thread_object_id)
        add_to!(new_hash, runtime_context)

        new_hash
      end

      def add_to!(hash, object)
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
        hash
      end

      # Hook to clear any caching implement in this class
      def expire_cache!
        @snapshot = nil
      end
  end
end
