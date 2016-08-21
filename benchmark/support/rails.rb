require "rails"
require "action_controller"
require "timber"
require "stringio"

# Helper methods
module Support
  module Rails
    def self.dispatch_rails_request(path)
      application = ::Rails.application
      env = application.respond_to?(:env_config) ? application.env_config.clone : application.env_defaults.clone
      env["rack.request.cookie_hash"] = {}.with_indifferent_access
      ::Rack::MockRequest.new(application).get(path, env)
    end

    def self.set_logger(log_dev)
      logger = defined?(::ActiveSupport::Logger) ? ::ActiveSupport::Logger.new(log_dev) : ::Logger.new(log_dev)
      ::Rails.logger = defined?(::ActiveSupport::TaggedLogging) ? ::ActiveSupport::TaggedLogging.new(logger) : logger
      ::Rails.logger.level = ::Logger::DEBUG # log everything
    end

    def self.set_timber_logger
      ::Rails.logger = Timber::Logger.new(Timber::LogDevices::IO.new(StringIO.new))
      ::Rails.logger.level = ::Logger::DEBUG # log everything
    end
  end
end

# Disable by default
Timber::Config.enabled = false

# Setup default rails logger with StringIO.
# This ensures that the log data isn't output, but the level is sufficient
# to be logged.
Support::Rails.set_logger(StringIO.new)

# Base rails app
class RailsApp < Rails::Application
  if ::Rails.version =~ /^3\./
    config.secret_token = '1e05af2b349457936a41427e63450937'
  else
    config.secret_key_base = '1e05af2b349457936a41427e63450937'
  end
  config.active_support.deprecation = :stderr
  config.eager_load = false
end

# Start the app to get initialization out of the way
RailsApp.initialize!

# Setup a controller
class PagesController < ActionController::Base
  layout nil

  def index
    # Similuate above average logging for a single action
    25.times { Rails.logger.info("this is a test log message") }
    render json: {}
  end

  def method_for_action(action_name)
    action_name
  end
end

# Some routes
::RailsApp.routes.draw do
  get '/' => 'pages#index'
end

# Dispatch a request to get the initial caching / loading out of the way
Support::Rails.dispatch_rails_request("/")
