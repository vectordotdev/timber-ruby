# core classes
require "json" # brings to_json to the Hash class

# Base (must come first, order matters)
require "timber/patterns"
require "timber/config"
require "timber/context"
require "timber/probe"

# Other (sorted alphabetically)
require "timber/contexts"
require "timber/current_context"
require "timber/log_device_installer"
require "timber/log_line"
require "timber/log_pile"
require "timber/log_truck"
require "timber/probes"
require "timber/system"

# Load frameworks last
require "timber/frameworks"
