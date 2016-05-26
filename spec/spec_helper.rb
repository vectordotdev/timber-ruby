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
logger = Logger.new(STDOUT, Logger::DEBUG)
Timber::Config.logger = logger

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.warnings = false
end
