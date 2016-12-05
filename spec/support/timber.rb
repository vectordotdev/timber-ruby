# Must require last in order to be mocked via webmock
require 'timber'

Timber::Config.instance.logger = Timber::Logger.new(STDOUT)