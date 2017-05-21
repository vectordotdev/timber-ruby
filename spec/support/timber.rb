require "timber"

config = Timber::Config.instance
config.append_metadata = true
config.debug_to_stdout