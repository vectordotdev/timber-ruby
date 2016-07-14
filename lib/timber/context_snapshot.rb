module Timber
  class ContextSnapshot
    attr_reader :indexes, :stack

    def initialize
      # Cloning arrays and hashes is extremely fast. This
      # should not be a concern for hindering performance as we are
      # only cloning the structures, not the content.
      @stack = CurrentContext.stack.clone.freeze
      @indexes = CurrentLineIndexes.indexes.clone.freeze
    end

    def as_json(*args)
      @as_json ||= {
        indexes: indexes_hash,
        hierarchy: hierarchy,
        data: stack_hash
      }
    end

    def to_json(*args)
      # Note: this is run in the background thread, hence the hash creation.
      @json ||= as_json.to_json(*args)
    end

    def hierarchy
      @hierarchy ||= stack.collect(&:key_name)
    end

    def size
      stack.size
    end

    private
      def indexes_hash
        @indexes_hash ||= {}.tap do |hash|
          indexes.each do |context, index|
            hash[context.key_name] = index
          end
        end
      end

      def stack_hash
        @stack_hash ||= stack.group_by(&:key_name)
      end
  end
end
