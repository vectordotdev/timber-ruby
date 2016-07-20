module Timber
	class Logger < ::Logger
		# Add silencer if defined.
		include ::LoggerSilence if defined?(::LoggerSilence)

    class LogDevice
    	def close(*args)
    	end

    	def write(message)
    		LogPile.drop_message(message)
	      message
	    rescue LogLine::InvalidMessageError => e
	    	Config.logger.exception(e)
	    	false
	    end
    end

    class SimpleFormatter < ::Logger::Formatter
      # This method is invoked when a log event occurs
      def call(severity, timestamp, progname, msg)
        "#{String === msg ? msg : msg.inspect}\n"
      end
    end

    # Broadcasts logs to multiple loggers.
    def self.broadcast(logger) # :nodoc:
      Module.new do
        define_method(:add) do |*args, &block|
          logger.add(*args, &block)
          super(*args, &block)
        end

        define_method(:<<) do |x|
          logger << x
          super(x)
        end

        define_method(:close) do
          logger.close
          super()
        end

        define_method(:progname=) do |name|
          logger.progname = name
          super(name)
        end

        define_method(:formatter=) do |formatter|
          logger.formatter = formatter
          super(formatter)
        end

        define_method(:level=) do |level|
          logger.level = level
          super(level)
        end

        define_method(:local_level=) do |level|
          logger.local_level = level if logger.respond_to?(:local_level=)
          super(level) if respond_to?(:local_level=)
        end

        define_method(:silence) do |level = Logger::ERROR, &block|
          if logger.respond_to?(:silence)
            logger.silence(level) do
              if respond_to?(:silence)
                super(level, &block)
              else
                block.call(self)
              end
            end
          else
            if respond_to?(:silence)
              super(level, &block)
            else
              block.call(self)
            end
          end
        end
      end
    end

		attr_writer :application_key
    attr_accessor :level

    def initialize(application_key = nil, level = nil)
    	self.application_key = application_key
      self.level = level || ENV['LOG_LEVEL'] || DEBUG
      super(LogDevice.new)
      @formatter = SimpleFormatter.new
    end

    def application_key
    	@application_key || Config.application_key
    end

    # Dynamically add methods such as:
    # def info?
    # def warn?
    # def debug?
    for severity in ::Logger::Severity.constants
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{severity.downcase}?
          #{severity} >= level
        end
      EOT
    end
	end
end