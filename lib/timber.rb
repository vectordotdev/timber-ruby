# core classes
require "json" # brings to_json to the core classes

begin
  require "rails_stdout_logging"
  module RailsStdoutLogging
    class Rails3 < Rails
      def self.set_logger(config)
      end
    end
  end
rescue Exception
end

# Base (must come first, order matters)
require "timber/config"
require "timber/context"
require "timber/event"
require "timber/probe"
require "timber/util"
require "timber/version"

# Other (sorted alphabetically)
require "timber/contexts"
require "timber/current_context"
require "timber/events"
require "timber/log_devices"
require "timber/log_entry"
require "timber/logger"
require "timber/probes"
require "timber/rack_middlewares"

# Load frameworks
require "timber/frameworks"