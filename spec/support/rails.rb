require "rails"

Rails.logger = Timber::Logger.new(STDOUT)
Rails.logger.level = ::Logger::FATAL

class RailsApp < Rails::Application
  if ::Rails.version =~ /^3\./
    config.secret_token = '1e05af2b349457936a41427e63450937'
  else
    config.secret_key_base = '1e05af2b349457936a41427e63450937'
  end
  config.active_support.deprecation = :stderr
  config.eager_load = false
  config.log_level = :fatal
end

RailsApp.initialize!

module Support
  module Rails
    def dispatch_rails_request(path)
      application = ::Rails.application
      env = application.respond_to?(:env_config) ? application.env_config.clone : application.env_defaults.clone
      env["rack.request.cookie_hash"] = {}.with_indifferent_access
      ::Rack::MockRequest.new(application).get(path, env)
    end
  end
end

RSpec.configure do |config|
  config.include Support::Rails
end
