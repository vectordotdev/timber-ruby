require 'benchmark'
require 'benchmark-memory'
require 'bundler/setup'
require 'rails'
require 'action_controller'

io = StringIO.new # ensure we are logging to something
logger = Logger.new(io)
logger.level = Logger::DEBUG
Rails.logger = logger

#
# Setup
#

# Setup the rails app to test
class RailsApp < Rails::Application
  if ::Rails.version =~ /^3\./
    config.secret_token = '1e05af2b349457936a41427e63450937'
  else
    config.secret_key_base = '1e05af2b349457936a41427e63450937'
  end

  # This ensures our tests fail, otherwise exceptions get swallowed by ActionDispatch::DebugExceptions
  config.action_dispatch.show_exceptions = false
  config.active_support.deprecation = :stderr
  config.eager_load = false
end

# Create a controller to test against
class HomeController < ActionController::Base
  layout nil

  def index
    render json: {}
  end

  def method_for_action(action_name)
    action_name
  end
end

# Define the routes
::RailsApp.routes.draw do
  get '/' => 'home#index'
end

# Initialize the app
RailsApp.initialize!

# Helper function to issue requests.
def dispatch_rails_request(path, additional_env_options = {})
  application = ::Rails.application
  env = application.respond_to?(:env_config) ? application.env_config.clone : application.env_defaults.clone
  env["rack.request.cookie_hash"] = {}.with_indifferent_access
  env["REMOTE_ADDR"] = "123.456.789.10"
  env["HTTP_X_REQUEST_ID"] = "unique-request-id-1234"
  env["action_dispatch.request_id"] = env["HTTP_X_REQUEST_ID"]
  env = env.merge(additional_env_options)
  ::Rack::MockRequest.new(application).get(path, env)
end

# How many iterations to perform
iterations = 1_000

puts "############################################################"
puts ""
puts "Testing Without Timber (#{iterations} iterations)"
puts ""
puts "############################################################"
puts

# Use bmbm to mimimize initial GC differences.
puts "Timing via benchmark:"
puts ""

Benchmark.bmbm do |x|
  x.report("Without Timber") { iterations.times { dispatch_rails_request("/") } }
end

puts "\n"
puts "Memory profiling via benchmark-memory:"
puts

Benchmark.memory do |x|
  x.report("Without Timber") { iterations.times { dispatch_rails_request("/") } }
end

puts "\n\n\n\n"
puts "############################################################"
puts ""
puts "Testing With Timber (#{iterations} iterations)"
puts ""
puts "############################################################"
puts ""

# Integrate Timber (this is handled in our Railtie, but we cna't use that here since we already
# initialized the app.)
require 'timber'
io = StringIO.new # ensure we are logging to something
logger = Timber::Logger.new(io)
logger.level = Logger::DEBUG

# ::ActionCable::Server::Base.logger = logger if defined?(::ActionCable::Server::Base) && ::ActionCable::Server::Base.respond_to?(:logger=)
# ::ActionController::Base.logger = logger if defined?(::ActionController::Base) && ::ActionController::Base.respond_to?(:logger=)
# ::ActionMailer::Base.logger = logger if defined?(::ActionMailer::Base) && ::ActionMailer::Base.respond_to?(:logger=)
# ::ActionView::Base.logger = logger if defined?(::ActionView::Base) && ::ActionView::Base.respond_to?(:logger=)
# ::ActiveRecord::Base.logger = logger if defined?(::ActiveRecord::Base) && ::ActiveRecord::Base.respond_to?(:logger=)
# ::Rails.logger = logger

# Timber::Integrations::Rack.middlewares.each do |middleware|
#   Rails.application.config.app_middleware.use middleware
# end

#Timber::Integrations.integrate!

puts "Timing via benchmark:"
puts ""

Benchmark.bmbm do |x|
  x.report("With Timber")  { iterations.times { dispatch_rails_request("/") } }
end

puts "\n"
puts "Memory profiling via benchmark-memory:"
puts ""

Benchmark.memory do |x|
  x.report("With Timber") { iterations.times { dispatch_rails_request("/") } }
end