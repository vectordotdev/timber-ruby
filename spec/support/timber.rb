require "timber"
require "timber/cli"
require "timber/cli/io"
require "timber/config"

config = Timber::Config.instance
config.environment = "production"