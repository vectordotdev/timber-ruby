require "timber"

config = Timber::Config.instance
config.append_metadata = true
logger = ::Logger.new(nil)
config.debug_logger = logger