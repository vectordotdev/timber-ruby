require "logger"

module Timber
  class Logger < ::Logger
    class UnsupportedEventTypeError < RuntimeError
      def new(obj)
        super(
          "#{obj.class} does not respond to #to_timber_event, custom events must conform to " +
          "this interface to be logged"
        )
      end
    end

    class Formatter
      SEVERITY_MAP = {
        ::Logger::Severity::DEBUG => :debug,
        ::Logger::Severity::INFO => :info,
        ::Logger::Severity::WARN => :warn,
        ::Logger::Severity::ERROR => :error,
        ::Logger::Severity::FATAL => :datal,
        ::Logger::Severity::UNKNOWN => :unknown
      }

      private
        def build_log_entry(severity, time, progname, msg)
          level = SEVERITY_MAP.fetch(severity)
          context = CurrentContext.instance.snapshot
          event = Events.build(msg) || raise(UnsupportedEventTypeError.new(msg))
          LogEntry.new(level, time, progname, msg, context, event)
        end
    end

    class JSONFormatter < Formatter
      def call(severity, time, progname, msg)
        build_log_entry(severity, time, progname, msg).to_json()
      end
    end

    class HybridFormatter < Formatter
      METADATA_CALLOUT = "@timber.io".freeze

      def call(severity, time, progname, msg)
        log_entry = build_log_entry(severity, time, progname, msg)
        metadata = log_entry.to_json(:except => :message)
        "#{log_entry.message} #{METADATA_CALLOUT} #{metadata}"
      end
    end

    def initilize(*args)
      logger = super()
      logger.formatter = HybridFormatter.new
    end
  end
end