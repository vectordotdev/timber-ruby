module Timber
  # Holds the log line counts on a per context basis in memory.
  class CurrentLineIndexes
    THREAD_NAMESPACE = :_timber_current_line_counts.freeze

    include Patterns::DelegatedSingleton

    def context_added(context)
      indexes[context] = 0
    end

    def context_removed(context)
      indexes.delete(context)
    end

    def indexes
      Thread.current[THREAD_NAMESPACE] ||= {}
    end

    def increment
      indexes.each do |context, _index|
        indexes[context] += 1
      end
    end

    def snapshot
      # No need to cache, this is blown out for each log line
      LineIndexesSnapshot.new(self)
    end
  end
end
