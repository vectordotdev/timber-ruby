module Support
  module Rails
    def with_rails_app(example)
      setup_rails_app
      example.run
      reset_rails_app
    end

    def setup_rails_app
      # Mock rails app for testing
      app = Class.new ::Rails::Application do
        if ::Rails.version =~ /^3\./
          config.secret_token = '1e05af2b349457936a41427e63450937'
        else
          config.secret_key_base = '1e05af2b349457936a41427e63450937'
        end
        config.active_support.deprecation = :stderr
        config.logger = LOGGER
        config.eager_load = false
      end

      ::ActionController::Base.prepend_view_path("#{File.dirname(__FILE__)}/rails/templates")
      ::ActionController::Base.logger = LOGGER
      ::ActiveRecord::Base.logger = LOGGER
      ::ActionView::Base.logger = LOGGER if ::ActionView::Base.respond_to?(:logger=)

      Object.const_set(:RailsApp, app)

      ::RailsApp.class_eval do
        def self.reset_instance
          class_variable_set(:@@instance, nil)
        end
      end
    end

    def initialize_rails_app
      ::RailsApp.initialize!
    end

    def reset_rails_app
      ::RailsApp.reset_instance
      ::Rails.application = nil
      Object.send(:remove_const, :RailsApp)
    end

    def dispatch_rails_request(controller, action)
      if controller.method(:dispatch).arity == 3
        controller.dispatch(action, request, ActionDispatch::TestResponse.new)
      else
        controller.dispatch(action, request)
      end
    end
  end
end

RSpec.configure do |config|
  config.include Support::Rails
end
