require "timber"

Timber::Config.instance.debug_logger = ::Logger.new(STDOUT)