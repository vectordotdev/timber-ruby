require "timber"

config = Timber::Config.instance
config.append_metadata = true
logger = ::Logger.new(STDOUT)
logger.level = :error
config.debug_logger = logger