module Timber
  # Base class for all `Timber::Contexts::*` classes.
  # @private
  class Context
    class << self
      # The keyspace is the key used when storing the context.
      # For example:
      #
      #     {:build => {:version => "1.0.0"}}
      #
      # The keyspace in the above context is `:build`. This is required
      # because it prevents key name conflicts. Without the keyspace
      # it very possible another context type might also have a `:version`
      # attribute.
      def keyspace
        @keyspace || raise(NotImplementedError.new)
      end
    end

    def keyspace
      self.class.keyspace
    end
  end
end
