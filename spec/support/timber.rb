require "timber"
require "timber/cli"
require "timber/cli/io"
require "timber/config"

config = Timber::Config.instance
config.environment = "production"
config.debug_to_stdout