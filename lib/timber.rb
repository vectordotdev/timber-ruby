# core classes
require "json" # brings to_json to the core classes

require "timber/overrides/rails_stdout_logging"

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