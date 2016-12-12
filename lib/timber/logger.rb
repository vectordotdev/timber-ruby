require "logger"

module Timber
  # The Timber Logger behaves exactly like `::Logger`, except that it supports a transparent API
  # for logging structured messages. It ensures your log messages are communicated properly
  # with the Timber.io API.
  #
  # To adhere to our no code debt / no lock-in promise, the Timber Logger will *never* deviate
  # from the `::Logger` interface. That is, it will *never* add methods, or alter any
  # method signatures. This ensures Timber can be removed without consequence.
  #
  # @example Basic example (the original ::Logger interface remains untouched):
  #   logger.info "Payment rejected for customer #{customer_id}"
  #
  # @example Using a map
  #   # The :message, :type, and :data keys are required
  #   logger.info message: "Payment rejected", type: :payment_rejected, data: {customer_id: customer_id, amount: 100}
  #
  # @example Using a Struct (a simple, more structured way, to define events)
  #   PaymentRejectedEvent = Struct.new(:customer_id, :amount, :reason) do
  #     def message; "Payment rejected for #{customer_id}"; end
  #     def type; :payment_rejected; end
  #   end
  #   Logger.info PaymentRejectedEvent.new("abcd1234", 100, "Card expired")
  #
  # @example Using typed Event classes
  #   # Event implementation is left to you. Events should be simple classes.
  #   # The only requirement is that it responds to #to_timber_event and return the
  #   # appropriate Timber::Events::* type.
  #   class Event
  #     def to_hash
  #       hash = {}
  #       instance_variables.each { |var| hash[var.to_s.delete("@")] = instance_variable_get(var) }
  #       hash
  #     end
  #     alias to_h to_hash
  #
  #     def to_timber_event
  #       Timber::Events::Custom.new(type: type, message: message, data: to_hash)
  #     end
  #
  #     def message; raise NotImplementedError.new; end
  #     def type; raise NotImplementedError.new; end
  #   end
  #
  #   class PaymentRejectedEvent < Event
  #     attr_accessor :customer_id, :amount
  #     def initialize(customer_id, amount)
  #       @customer_id = customer_id
  #       @amount = amount
  #     end
  #     def message; "Payment rejected for customer #{customer_id}"; end
  #     def type; :payment_rejected_event; end
  #   end
  #
  #   Logger.info PymentRejectedEvent.new("abcd1234", 100)
  #
  class Logger < ::Logger
    # @private
    class Formatter
      # Formatters get the formatted level from the logger.
      SEVERITY_MAP = {
        "DEBUG" => :debug,
        "INFO" => :info,
        "WARN" => :warn,
        "ERROR" => :error,
        "FATAL" => :datal,
        "UNKNOWN" => :unknown
      }

      private
        def build_log_entry(severity, time, progname, msg)
          level = SEVERITY_MAP.fetch(severity)
          context = CurrentContext.instance.snapshot
          event = Events.build(msg)
          if event
            LogEntry.new(level, time, progname, event.message, context, event)
          else
            LogEntry.new(level, time, progname, msg, context, nil)
          end
        end
    end

    # Structures your log messages into JSON.
    #
    #   logger = Timber::Logger.new(STDOUT)
    #   logger.formatter = Timber::JSONFormatter.new
    #
    # Example message:
    #
    #   {"level":"info","dt":"2016-09-01T07:00:00.000000-05:00","message":"My log message"}
    #
    class JSONFormatter < Formatter
      def call(severity, time, progname, msg)
        # use << for concatenation for performance reasons
        build_log_entry(severity, time, progname, msg).to_json() << "\n"
      end
    end

    # Structures your log messages into Timber's hybrid format, which makes
    # it easy to read while also appending the appropriate metadata.
    #
    #   logger = Timber::Logger.new(STDOUT)
    #   logger.formatter = Timber::JSONFormatter.new
    #
    # Example message:
    #
    #   My log message @timber.io {"level":"info","dt":"2016-09-01T07:00:00.000000-05:00"}
    #
    class HybridFormatter < Formatter
      METADATA_CALLOUT = "@timber.io".freeze

      def call(severity, time, progname, msg)
        log_entry = build_log_entry(severity, time, progname, msg)
        metadata = log_entry.to_json(:except => [:message])
        # use << for concatenation for performance reasons
        log_entry.message << " " << METADATA_CALLOUT << " " << metadata << "\n"
      end
    end

    # Creates a new Timber::Logger instances. Accepts the same arguments as `::Logger.new`.
    # The only difference is that it default the formatter to {HybridFormatter}. Using
    # a different formatter is easy. For example, if you prefer your logs in JSON.
    #
    # @example Changing your formatter
    #   logger = Timber::Logger.new(STDOUT)
    #   logger.formatter = Timber::Logger::JSONFormatter.new
    def initialize(*args)
      super(*args)
      self.formatter = HybridFormatter.new
    end

    # Backwards compatibility with older ActiveSupport::Logger versions
    Logger::Severity.constants.each do |severity|
      class_eval(<<-EOT, __FILE__, __LINE__ + 1)
        def #{severity.downcase}?                # def debug?
          Logger::#{severity} >= level           #   DEBUG >= level
        end                                      # end
      EOT
    end
  end
end