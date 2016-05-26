# Base
require 'rubygems'
require 'bundler/setup'
require 'rails'

# Testing
require 'rspec'
require 'rspec/its'

# Support files
Dir[File.expand_path(File.join(File.dirname(__FILE__), 'support', '**', '*.rb'))].each {|f| require f}

# Must require last in order to be mocked via webmock
require 'timber'

# Config
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG
Timber::Config.tap do |config|
  config.logger = logger

  # Turn this off for testing, no reason to spin up a thread
  # and send network calls unless the test explicitly calls
  # for it.
  config.log_truck_enabled = false
end

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.warnings = false
end
