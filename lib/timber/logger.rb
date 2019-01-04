require "logger"
require "msgpack"

require "timber/config"
require "timber/current_context"
require "timber/log_devices"
require "timber/log_entry"

module Timber
  # The Timber Logger behaves exactly like the standard Ruby `::Logger`, except that it supports a
  # transparent API for logging structured data and events.
  #
  # @example Basic logging
  #   logger.info "Payment rejected for customer #{customer_id}"
  #
  # @example Logging an event
  #   logger.info "Payment rejected", payment_rejected: {customer_id: customer_id, amount: 100}
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
      EMPTY_ARRAY = []

      private
        def build_log_entry(severity, time, progname, logged_obj)
          context_snapshot = CurrentContext.instance.snapshot
          level = SEVERITY_MAP.fetch(severity)
          tags = extract_active_support_tagged_logging_tags

          if logged_obj.is_a?(Event)
            LogEntry.new(level, time, progname, logged_obj.message, context_snapshot, logged_obj,
                         tags: tags)
          elsif logged_obj.is_a?(Hash)
            # Extract the tags
            tags = tags.clone
            tags.push(logged_obj.delete(:tag)) if logged_obj.key?(:tag)
            tags.concat(logged_obj.delete(:tags)) if logged_obj.key?(:tags)
            tags.uniq!

            message = logged_obj.delete(:message)

            LogEntry.new(level, time, progname, message, context_snapshot, logged_obj, tags: tags)
          else
            LogEntry.new(level, time, progname, logged_obj, context_snapshot, nil, tags: tags)
          end
        end

        # Because of all the crazy ways Rails has attempted tags, we need this crazy method.
        def extract_active_support_tagged_logging_tags
          Thread.current[:activesupport_tagged_logging_tags] ||
            Thread.current[tagged_logging_object_key_name] ||
            EMPTY_ARRAY
        end

        def tagged_logging_object_key_name
          @tagged_logging_object_key_name ||= "activesupport_tagged_logging_tags:#{object_id}"
        end
    end

    # For use in development and test environments where you do not want metadata
    # included in the log lines.
    class MessageOnlyFormatter < Formatter
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
    class AugmentedFormatter < Formatter
      METADATA_CALLOUT = " @metadata ".freeze
      NEW_LINE = "\n".freeze
      ESCAPED_NEW_LINE = "\\n".freeze

      def call(severity, time, progname, msg)
        log_entry = build_log_entry(severity, time, progname, msg)
        metadata = log_entry.to_json(:except => [:message])
        # use << for concatenation for performance reasons
        log_entry.message.gsub(NEW_LINE, ESCAPED_NEW_LINE) << METADATA_CALLOUT <<
          metadata << NEW_LINE
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

    # Creates a new Timber::Logger instance where the passed argument is an IO device. That is,
    # anything that responds to `#write` and `#close`.
    #
    # Note, this method does *not* accept the same arguments as the standard Ruby `::Logger`.
    # The Ruby `::Logger` accepts additional options controlling file rotation if the first argument
    # is a file *name*. This is a design flaw that Timber does not assume. Logging to a file, or
    # multiple IO devices is demonstrated in the examples below.
    #
    # @example Logging to STDOUT
    #   logger = Timber::Logger.new(STDOUT)
    #
    # @example Logging to the Timber HTTP device
    #   http_device = Timber::LogDevices::HTTP.new("my-timber-api-key")
    #   logger = Timber::Logger.new(http_device)
    #
    # @example Logging to a file (with rotation)
    #   file_device = Logger::LogDevice.new("path/to/file.log")
    #   logger = Timber::Logger.new(file_device)
    #
    # @example Logging to a file and the Timber HTTP device (multiple log devices)
    #   http_device = Timber::LogDevices::HTTP.new("my-timber-api-key")
    #   file_logger = ::Logger.new("path/to/file.log")
    #   logger = Timber::Logger.new(http_device, file_logger)
    def initialize(*io_devices_and_loggers)
      if io_devices_and_loggers.size == 0
        raise ArgumentError.new("At least one IO device or Logger must be provided when " +
          "instantiating a Timber::Logger. Ex: Timber::Logger.new(STDOUT).")
      end

      @extra_loggers = io_devices_and_loggers[1..-1].collect do |obj|
        if is_a_logger?(obj)
          obj
        else
          self.class.new(obj)
        end
      end

      io_device = io_devices_and_loggers[0]

      super(io_device)

      # Ensure we sync STDOUT to avoid buffering
      if io_device.respond_to?(:"sync=")
        io_device.sync = true
      end

      # Set the default formatter. The formatter cannot be set during
      # initialization, and can be changed with #formatter=.
      if io_device.is_a?(LogDevices::HTTP)
        self.formatter = PassThroughFormatter.new
      elsif Config.instance.development? || Config.instance.test?
        self.formatter = MessageOnlyFormatter.new
      else
        self.formatter = JSONFormatter.new
      end

      self.level = environment_level

      after_initialize if respond_to?(:after_initialize)

      Timber::Config.instance.debug { "Timber::Logger instantiated, level: #{level}, formatter: #{formatter.class}" }

      @initialized = true
    end

    # Sets a new formatted on the logger.
    #
    # @note The formatter cannot be changed if you are using the HTTP logger backend.
    def formatter=(value)
      if @initialized && @logdev && @logdev.dev.is_a?(Timber::LogDevices::HTTP) && !value.is_a?(PassThroughFormatter)
        raise ArgumentError.new("The formatter cannot be changed when using the " +
          "Timber::LogDevices::HTTP log device. The PassThroughFormatter must be used for proper " +
          "delivery.")
      end

      super
    end

    def level=(value)
      if value.is_a?(Symbol)
        value = level_from_symbol(value)
      end
      super
    end

    # @private
    def with_context(context, &block)
      Timber::CurrentContext.with(context, &block)
    end

    # Patch to ensure that the {#level} method is used instead of `@level`.
    # This is required because of Rails' monkey patching on Logger via `::LoggerSilence`.
    def add(severity, message = nil, progname = nil, &block)
      return true if @logdev.nil? || (severity || UNKNOWN) < level

      @extra_loggers.each do |logger|
        logger.add(severity, message, progname, &block)
      end

      super
    end

    # Backwards compatibility with older ActiveSupport::Logger versions
    Logger::Severity.constants.each do |severity|
      class_eval(<<-EOT, __FILE__, __LINE__ + 1)
        def #{severity.downcase}(*args, &block)
          progname = args.first
          options = args.last

          if args.length == 2 and options.is_a?(Hash) && options.length > 0
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

      def level_from_symbol(value)
        case value
        when :debug; DEBUG
        when :info;  INFO
        when :warn;  WARN
        when :error; ERROR
        when :fatal; FATAL
        when :unknown; UNKNOWN
        else; raise ArgumentError.new("level #{value.inspect} is not a valid logger level")
        end
      end

      def is_a_logger?(obj)
        obj.respond_to?(:debug) && obj.respond_to?(:info) && obj.respond_to?(:warn)
      end
  end
end
