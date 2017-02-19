module Timber
  module Probes
    # Reponsible for automatimcally tracking SQL query events in `ActiveRecord`, while still
    # preserving the default log style.
    class ActiveSupportTaggedLogging < Probe
      module FormatterMethods
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
          end
        end
      end

      module LoggerMethods
        def self.included(klass)
          klass.class_eval do
            def add(severity, message = nil, progname = nil, &block)
              if message.nil?
                if block_given?
                  message = block.call
                else
                  message = progname
                  progname = nil #No instance variable for this like Logger
                end
              end
              if @logger.is_a?(Timber::Logger)
                @logger.add(severity, message, progname)
              else
                @logger.add(severity, "#{tags_text}#{message}", progname)
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
        if defined?(ActiveSupport::TaggedLogging::Formatter)
          return true if ActiveSupport::TaggedLogging::Formatter.include?(FormatterMethods)
          ActiveSupport::TaggedLogging::Formatter.send(:include, FormatterMethods)
        else
          return true if ActiveSupport::TaggedLogging.include?(LoggerMethods)
          ActiveSupport::TaggedLogging.send(:include, LoggerMethods)
        end
      end
    end
  end
end