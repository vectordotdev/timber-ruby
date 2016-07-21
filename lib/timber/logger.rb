module Timber
	class Logger < defined?(::ActiveSupport::Logger) ? ::ActiveSupport::Logger : ::Logger
		# Add silencer if defined.
		include ::LoggerSilence if defined?(::LoggerSilence)

    class LogDevice
    	attr_reader :application_key

    	def initialize(application_key)
    		@application_key = application_key
    	end

    	def close(*args)
    	end

    	def write(message)
    		LogPile.get(application_key).drop_message(message)
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

    attr_reader :application_key

    def initialize(application_key = nil, level = nil)
    	@application_key = application_key || Config.application_key
    	if @application_key.nil?
    		raise ArgumentError.new("A Timber application_key is required")
    	end
      @level = level || Config.log_level
      super(LogDevice.new(@application_key))
      @formatter = SimpleFormatter.new
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