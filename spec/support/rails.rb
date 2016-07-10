# Mock rails app for testing
class ::RailsApp < Rails::Application
  if Rails.version =~ /^3\./
    config.secret_token = '1e05af2b349457936a41427e63450937'
  else
    config.secret_key_base = '1e05af2b349457936a41427e63450937'
  end
  config.active_support.deprecation = :stderr
  config.logger = Logger.new(STDOUT)
  config.eager_load = false
end

# Add a method to remove the instance so that we can start
# each test with a clean slate
::Rails::Application.class_eval do
  def self.reset_instance
    class_variable_set(:@@instance, nil)
  end
end

# Rspec helper
module Support
  module Rails
    def initialize_rails_app
      RailsApp.initialize!
    end

    def reset_rails_app
      ::Rails::Application.reset_instance
    end
  end
end

RSpec.configure do |config|
  config.include Support::Rails
end
