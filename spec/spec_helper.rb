# Base
require 'rubygems'
require 'bundler/setup'

# Testing
require 'rspec'
require 'rspec/its'
require 'rspec/mocks'

# Support files, order is relevant
require File.join(File.dirname(__FILE__), 'support', 'socket_hostname')
require File.join(File.dirname(__FILE__), 'support', 'timecop')
require File.join(File.dirname(__FILE__), 'support', 'webmock')
require File.join(File.dirname(__FILE__), 'support', 'timber')

RSpec::Support::ObjectFormatter.default_instance.max_formatted_output_length = 5_000

RSpec.configure do |config|
  config.color = true
  config.order = :random
  config.warnings = false
end
