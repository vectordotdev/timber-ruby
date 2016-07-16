# Base
require 'rubygems'
require 'bundler/setup'

# Testing
require 'pry'
require 'rspec'
require 'rspec/its'
require 'rspec/mocks'

# Support files, order is relevant
require File.join(File.dirname(__FILE__), 'support', 'simplecov')
require File.join(File.dirname(__FILE__), 'support', 'timecop')
require File.join(File.dirname(__FILE__), 'support', 'webmock')
require File.join(File.dirname(__FILE__), 'support', 'timber')
require File.join(File.dirname(__FILE__), 'support', 'rails')
require File.join(File.dirname(__FILE__), 'support', 'action_controller')
require File.join(File.dirname(__FILE__), 'support', 'action_view')
require File.join(File.dirname(__FILE__), 'support', 'active_record')
require File.join(File.dirname(__FILE__), 'support', 'log_pile')
require File.join(File.dirname(__FILE__), 'support', 'rails')

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.warnings = false
end
