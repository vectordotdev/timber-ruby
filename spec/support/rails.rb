require "rails"

# Defualt the rails logger to nothing, each test shoould be
# responsible for setting up the logger
logger = ::Logger.new(nil)
Rails.logger = logger

class RailsApp < Rails::Application
  if ::Rails.version =~ /^3\./
    config.secret_token = '1e05af2b349457936a41427e63450937'
  else
    config.secret_key_base = '1e05af2b349457936a41427e63450937'
  end
  config.active_support.deprecation = :stderr
  config.eager_load = false
end

RailsApp.initialize!

module Support
  module Rails
    def dispatch_rails_request(path, additional_env_options = {})
      application = ::Rails.application
      env = application.respond_to?(:env_config) ? application.env_config.clone : application.env_defaults.clone
      env["rack.request.cookie_hash"] = {}.with_indifferent_access
      env["REMOTE_ADDR"] = "123.456.789.10"
      env["X-Request-Id"] = "unique-request-id-1234"
      env["action_dispatch.request_id"] = env["X-Request-Id"]
      env = env.merge(additional_env_options)
      ::Rack::MockRequest.new(application).get(path, env)
    end
  end
end

RSpec.configure do |config|
  config.include Support::Rails
end
