require "logger"
require "msgpack"

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
  # @example Using a Hash
  #   # The :message key is required, the other additional key is your event type and data
  #   # :type is the namespace used in timber for the :data
  #   logger.info "Payment rejected", payment_rejected: {customer_id: customer_id, amount: 100}
  #
  # @example Using a Struct (a simple, more structured way, to define events)
  #   PaymentRejectedEvent = Struct.new(:customer_id, :amount, :reason) do
  #     # `#message` and `#type` are required, otherwise they will not be logged properly.
  #     # `#type` is the namespace used in timber for the struct data
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
        "FATAL" => :fatal,
        "UNKNOWN" => :unknown
      }

      private
        def build_log_entry(severity, time, progname, msg)
          level = SEVERITY_MAP.fetch(severity)
          context_snapshot = CurrentContext.instance.snapshot

          tags = extract_active_support_tagged_logging_tags
          time_ms = nil
          if msg.is_a?(Hash)
            if msg.key?(:tag) || msg.key?(:tags)
              tags = tags.clone
              tags << msg.delete(:tag) if msg.key?(:tag)
              tags += msg.delete(:tags) if msg.key?(:tags)
              tags.uniq!
            end
            time_ms = msg.delete(:time_ms) if msg.key?(:time_ms)

            msg = msg[:message] if msg.length == 1
          end

          event = Events.build(msg)

          if event
            LogEntry.new(level, time, progname, event.message, context_snapshot, event, tags: tags, time_ms: time_ms)
          else
            LogEntry.new(level, time, progname, msg, context_snapshot, nil, tags: tags, time_ms: time_ms)
          end
        end

        # Because of all the crazy ways Rails has attempted this we need this crazy method.
        def extract_active_support_tagged_logging_tags
          Thread.current[:activesupport_tagged_logging_tags] ||
            Thread.current["activesupport_tagged_logging_tags:#{object_id}"] ||
            []
        end
    end

    # For use in development and test environments where you do not want metadata
    # included in the log lines.
    class SimpleFormatter < Formatter

      # This method is invoked when a log event occurs
      def call(severity, timestamp, progname, msg)
        log_entry = build_log_entry(severity, timestamp, progname, msg)
        log_entry.to_s
      end
    end

    # Structures your log messages as strings and appends metadata if
    # `Timber::Config.instance.append_metadata?` is true.
    #
    # Example message with metdata:
    #
    #   My log message @metadata {"level":"info","dt":"2016-09-01T07:00:00.000000-05:00"}
    #
    class StringFormatter < Formatter
      METADATA_CALLOUT = "@metadata".freeze

      def call(severity, time, progname, msg)
        log_entry = build_log_entry(severity, time, progname, msg)

        if Config.instance.append_metadata?
          metadata = log_entry.to_json(:except => [:message])
          # use << for concatenation for performance reasons
          log_entry.message.gsub("\n", "\\n") << " " << METADATA_CALLOUT << " " << metadata << "\n"
        else
          log_entry.message + "\n"
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

    # Passes through the LogEntry object. This is specifically used for the {Timber::LogDevices::HTTP}
    # class. This allows the IO device to format it however it wants. This is neccessary for
    # MessagePack because it requires a fixed array size before encoding. And since HTTP is
    # sending data in batches, the encoding should happen there.
    class PassThroughFormatter < Formatter
      def call(severity, time, progname, msg)
        build_log_entry(severity, time, progname, msg)
      end
    end

    # These are rails modules that change the logger behavior. We have to
    # include these if they are present or the logger will not function properly
    # in a rails environment.
    include ::ActiveSupport::LoggerThreadSafeLevel if defined?(::ActiveSupport::LoggerThreadSafeLevel)
    include ::LoggerSilence if defined?(::LoggerSilence)

    # Creates a new Timber::Logger instances. Accepts the same arguments as `::Logger.new`.
    # The only difference is that it default the formatter to {HybridFormatter}. Using
    # a different formatter is easy. For example, if you prefer your logs in JSON.
    #
    # @example Changing your formatter
    #   logger = Timber::Logger.new(STDOUT)
    #   logger.formatter = Timber::Logger::JSONFormatter.new
    def initialize(*args)
      super(*args)

      # Ensure we sync STDOUT to avoid buffering
      if args.size == 1 and args.first.respond_to?(:"sync=")
        args.first.sync = true
      end

      if args.size == 1 and args.first.is_a?(LogDevices::HTTP)
        self.formatter = PassThroughFormatter.new
      else
        self.formatter = StringFormatter.new
      end

      self.level = environment_level

      after_initialize if respond_to?(:after_initialize)

      @initialized = true
    end

    def formatter=(value)
      if @initialized && @logdev && @logdev.dev.is_a?(Timber::LogDevices::HTTP) && !value.is_a?(PassThroughFormatter)
        raise ArgumentError.new("The formatter cannot be changed when using the " +
          "Timber::LogDevices::HTTP log device. The PassThroughFormatter must be used for proper " +
          "delivery.")
      end

      super
    end

    # Convenience method for adding context. Please see {{Timber::CurrentContext.with}} for
    # a more detailed description and examples.
    def with_context(context, &block)
      Timber::CurrentContext.with(context, &block)
    end

    # Backwards compatibility with older ActiveSupport::Logger versions
    Logger::Severity.constants.each do |severity|
      class_eval(<<-EOT, __FILE__, __LINE__ + 1)
        def #{severity.downcase}(*args, &block)
          progname = args.first
          options = args.last

          if args.length == 2 and options.is_a?(Hash) && options != {}
            progname = options.merge(message: progname)
          end

          add(#{severity}, nil, progname, &block)
        end

        def #{severity.downcase}?                # def debug?
          Logger::#{severity} >= level           #   DEBUG >= level
        end                                      # end
      EOT
    end

    private
      def environment_level
        level = ([ENV['LOG_LEVEL'].to_s.upcase, "DEBUG"] & %w[DEBUG INFO WARN ERROR FATAL UNKNOWN]).compact.first
        self.class.const_get(level)
      end
  end
end