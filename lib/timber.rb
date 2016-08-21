# core classes
require "json" # brings to_json to the core classes

# Base (must come first, order matters)
require "timber/macros"
require "timber/patterns"
require "timber/config"
require "timber/context"
require "timber/log_device"
require "timber/probe"
require "timber/version"

# Other (sorted alphabetically)
require "timber/api_settings"
require "timber/bootstrap"
require "timber/context_snapshot"
require "timber/contexts"
require "timber/current_context"
require "timber/current_line_indexes"
require "timber/ignore"
require "timber/internal_logger"
require "timber/log_devices"
require "timber/log_line"
require "timber/probes"

# Load frameworks last
require "timber/frameworks"
