module Timber
	class Logger < ::Logger
		# Add silencer if defined.
		include ::LoggerSilence if defined?(::LoggerSilence)

		module Severity
      DEBUG   = 0
      INFO    = 1
      WARN    = 2
      ERROR   = 3
      FATAL   = 4
      UNKNOWN = 5
    end
    include Severity

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
    for severity in Severity.constants
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{severity.downcase}?                                       # def debug?
          #{severity} >= level                                          #   DEBUG >= level
        end                                                             # end
      EOT
    end
	end
end