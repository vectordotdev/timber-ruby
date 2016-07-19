module Timber
	class Logger < ::Logger
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

    class << self
    	attr_writer :silencer
			def silencer
				return @silencer if defined?(@silencer)
				@silencer = true
			end
		end

    attr_accessor :application_key, :level

    def initialize(application_key = nil, level = nil)
    	self.application_key = application_key || Config.application_key
      self.level = level || ENV['LOG_LEVEL'] || DEBUG
      super(LogDevice.new)
      @formatter = SimpleFormatter.new
    end

    # Silences the logger for the duration of the block.
    def silence(temporary_level = ERROR)
      if silencer
        begin
          old_logger_level, self.level = level, temporary_level
          yield self
        ensure
          self.level = old_logger_level
        end
      else
        yield self
      end
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