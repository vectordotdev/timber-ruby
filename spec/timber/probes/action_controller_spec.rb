require "spec_helper"

describe Timber::Probes::ActionController do
  context Timber::Probes::ActionController::InstanceMethods do
    def dispatch(action)
      if controller.method(:dispatch).arity == 3
        controller.dispatch(action, request, ActionDispatch::TestResponse.new)
      else
        controller.dispatch(action, request)
      end
    end

    before(:each) do
      # This is only needed for older versions of rails because
      # ActionDispatch::TestRequest.new calls Rails.application.env_config
      # So we make a fake application and boot it so that it's not nil.
      class RailsApp < Rails::Application
        if Rails.version =~ /^3\./
          config.secret_token = '095f674153982a9ce59914b561f4522a'
        else
          config.secret_key_base = '095f674153982a9ce59914b561f4522a'
        end

        if Rails.version =~ /^3/
          # Workaround for initialization issue with 3.2
          #config.action_view.stylesheet_expansions = {}
          #config.action_view.javascript_expansions = {}
        end

        config.active_support.deprecation = :stderr

        config.logger = Logger.new(STDOUT)
        config.logger.level = Logger::DEBUG

        config.eager_load = false
      end

      RailsApp.initialize!

      Timber::Probes::ActionController.insert!

      class UsersController < ActionController::Base
        layout nil

        def index
          render json: {}
        end

        def method_for_action(action_name)
          action_name
        end
      end
    end

    after(:each) do
      Object.send(:remove_const, :RailsApp)
      Object.send(:remove_const, :UsersController)
      Rails.application = nil
    end

    let(:controller_class) { UsersController }
    let(:controller) { controller_class.new }
    let(:request) do
      ActionDispatch::TestRequest.new('REQUEST_METHOD' => 'GET', 'rack.input' => '')
    end
    let(:context_class) { Timber::Contexts::ActionController }

    describe "#process_action" do
      it "should set the context" do
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(context_class)).and_yield.once
        dispatch(:index)
      end
    end
  end
end
