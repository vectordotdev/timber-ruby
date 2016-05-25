# Base
require 'rubygems'
require 'bundler/setup'

# Testing
require 'rspec'
require 'rspec/its'
require 'webmock/rspec'

# Must require last in order to be mocked via webmock
require 'timber'

# Config
WebMock.disable_net_connect!

logger = Logger.new(STDOUT, Logger::DEBUG)
Timber::Config.logger = logger

RSpec.configure do |config|
  config.color = true
end
