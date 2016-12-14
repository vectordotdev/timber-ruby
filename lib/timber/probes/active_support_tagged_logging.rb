module Timber
  module Probes
    # Reponsible for automatimcally tracking SQL query events in `ActiveRecord`, while still
    # preserving the default log style.
    class ActiveSupportTaggedLogging < Probe
      module InstanceMethods
        def self.included(mod)
          mod.module_eval do
            alias_method :_timber_original_push_tags, :push_tags
            alias_method :_timber_original_pop_tags, :pop_tags

            def call(severity, timestamp, progname, msg)
              if is_a?(Timber::Logger::Formatter)
                # Don't convert the message into a string
                super(severity, timestamp, progname, msg)
              else
                super(severity, timestamp, progname, "#{tags_text}#{msg}")
              end
            end

            def push_tags(*tags)
              _timber_original_push_tags(*tags).tap do
                if current_tags.size > 0
                  context = Contexts::Tags.new(values: current_tags)
                  CurrentContext.add(context)
                end
              end
            end

            def pop_tags(size = 1)
              _timber_original_pop_tags(size).tap do
                if current_tags.size == 0
                  CurrentContext.remove(Contexts::Tags)
                else
                  context = Contexts::Tags.new(values: current_tags)
                  CurrentContext.add(context)
                end
              end
            end
          end
        end
      end

      def initialize
        require "active_support/tagged_logging"
      rescue LoadError => e
        raise RequirementNotMetError.new(e.message)
      end

      def insert!
        return true if ActiveSupport::TaggedLogging.include?(InstanceMethods)
        if defined?(ActiveSupport::TaggedLogging::Formatter)
          ActiveSupport::TaggedLogging::Formatter.send(:include, InstanceMethods)
        end
      end
    end
  end
end