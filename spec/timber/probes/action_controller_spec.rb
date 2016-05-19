require "spec_helper"

describe Timber::Probes::ActionController::InstanceMethods do
  before(:each) do
    # When running with Rails 3.0 this gets defined but is nil
    if defined?(Rails.application) && !Rails.application
      application = double(env_defaults: {}, env_config: {}, config: nil)
      allow(Rails).to receive(:application).and_return(application)
    end

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
    Object.send(:remove_const, :UsersController)
  end

  let(:controller_class) { UsersController }
  let(:controller) { controller_class.new }
  let(:request) do
    ActionDispatch::TestRequest.new('REQUEST_METHOD' => 'GET', 'rack.input' => '')
  end
  let(:context_class) { Timber::Contexts::ActionController }

  def dispatch(action)
    if controller.method(:dispatch).arity == 3
      controller.dispatch(action, request, ActionDispatch::TestResponse.new)
    else
      controller.dispatch(action, request)
    end
  end

  describe "#process_action" do
    it "should set the context" do
      expect(Timber::CurrentContext).to receive(:add).with(kind_of(context_class)).and_yield.once
      dispatch(:index)
    end
  end
end
