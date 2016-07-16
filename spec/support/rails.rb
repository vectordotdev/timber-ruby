# We want to test as if the app is in production
RAILS_ENV = "production"

require "rails"

class RailsApp < Rails::Application
  if ::Rails.version =~ /^3\./
    config.secret_token = '1e05af2b349457936a41427e63450937'
  else
    config.secret_key_base = '1e05af2b349457936a41427e63450937'
  end
  config.active_support.deprecation = :stderr
  config.logger = Logger.new(StringIO.new)
  config.log_level = :debug
  config.eager_load = false
end

RailsApp.initialize!

module Support
  module Rails
    def with_rails_app(example)
      setup_rails_app
      example.run
      reset_rails_app
    end

    def setup_rails_app
      # # Mock rails app for testing
      # app = Class.new ::Rails::Application do
      #   if ::Rails.version =~ /^3\./
      #     config.secret_token = '1e05af2b349457936a41427e63450937'
      #   else
      #     config.secret_key_base = '1e05af2b349457936a41427e63450937'
      #   end
      #   config.active_support.deprecation = :stderr
      #   config.logger = LOGGER
      #   config.log_level = :error
      #   config.eager_load = false
      # end

      # Object.const_set(:RailsApp, app)

      # ::Rails.class_eval do
      #   def self.reset
      #     # No idea why class variables are being used here, but we need to reset them
      #     # to reset state.
      #     class_variable_set(:@@instance, nil)
      #     ::Rails::Railtie::Configuration.class_variable_set(:@@app_middleware, nil)
      #   end
      # end
    end

    def initialize_rails_app
      # ::RailsApp.initialize!
    end

    def reset_rails_app
      # ::Rails.reset
      # ::Rails.application = nil
      # Object.send(:remove_const, :RailsApp)
    end

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
