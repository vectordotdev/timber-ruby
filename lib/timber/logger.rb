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

    class << self
    	attr_writer :silencer
			def silencer
				return @silencer if defined?(@silencer)
				@silencer = true
			end
		end

    attr_accessor :application_key, :level

    def initialize(application_key = nil, level = DEBUG)
    	self.application_key = application_key || Config.application_key
      self.level = level
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

    def add(severity, message = nil, progname = nil, &block)
      return if level > severity
      message = (message || (block && block.call) || progname).to_s
      LogPile.drop_message(message)
      message
    rescue LogLine::InvalidMessageError => e
    	Config.logger.exception(e)
    	false
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