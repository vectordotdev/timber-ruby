require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'timber'

logger = Logger.new(STDOUT)
logger.level = :debug
Timber::Config.logger = logger

RSpec.configure do |config|
  config.color = true
end
