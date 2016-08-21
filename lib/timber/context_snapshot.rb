module Timber
  class ContextSnapshot
    include Timber::Patterns::ToJSON

    CONTEXT_VERSION = 1.freeze

    attr_reader :indexes, :stack

    def initialize
      # Cloning arrays and hashes is extremely fast. This
      # should not be a concern for hindering performance as we are
      # only cloning the structures, not the content.
      @stack = CurrentContext.valid_stack.clone.freeze
      @indexes = CurrentLineIndexes.indexes.clone.freeze
    end

    def to_logfmt(options = {})
      @to_logfmt ||= {}
      @to_logfmt[options] ||= begin
        items = stack.collect do |context|
          next if options[:except].is_a?(Array) && options[:except].include?(context.class)
          # Delegate to #to_logfmt on the context object for caching.
          # Add the index on the fly, as a string, since it's more performant.
          context.to_logfmt + " #{context._path}#{Context::PATH_DELIMITER}_index=#{index(context)}"
        end.compact
        items << Macros::LogfmtEncoder.encode(:_version => CONTEXT_VERSION, :_hierarchy => hierarchy)
        Macros::LogfmtEncoder.join(*items)
      end
    end

    def size
      stack.size
    end

    private
      def context_hash
        @context_hash ||= {}.tap do |hash|
          hash = stack.inject(hash) do |hash, context|
            Macros::DeepMerger.merge(hash, context.as_json)
          end
          hash[:_version] = CONTEXT_VERSION
          hash[:_hierarchy] = hierarchy
        end
      end

      def hierarchy
        @hierarchy ||= stack.collect(&:_path).uniq
      end

      def index(context)
        indexes[context] || raise("couldn't find index for #{context}")
      end

      def json_payload
        @json_payload ||= {:context => context_hash}
      end
  end
end
