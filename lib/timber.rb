# Base (must come first, order matters)
require "timber/version"
require "timber/overrides"
require "timber/config"
require "timber/util"

# Other (sorted alphabetically)
require "timber/contexts"
require "timber/current_context"
require "timber/events"
require "timber/log_devices"
require "timber/log_entry"
require "timber/logger"
require "timber/integrations"
require "timber/timer"

# Load frameworks
require "timber/frameworks"

module Timber
  def self.debug(&block)
    debug_logger = Config.instance.debug_logger
    if debug_logger
      message = yield
      debug_logger.debug(message)
    end
    true
  end
end