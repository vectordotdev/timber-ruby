begin
	require "rails_stdout_logging/rails3"
rescue LoadError
end

module Timber
	module RailsStdoutLogging
		if defined?(::RailsStdoutLogging)
			Config.logger.warn "RailsStdoutLogging is installed. If you no longer want to log to STDOUT " +
				"please remove the rails_stdout_logging gem. Note this is a dependency of the " +
				"rails_12factor gem."

			::RailsStdoutLogging::Rails3.class_eval do
				def self.set_logger(*args)
				end
			end
		end
	end
end