require "spec_helper"

describe Timber::Probes::ActionView do
  describe described_class::InstanceMethods do
    before(:each) do
      setup_rails_app
      initialize_rails_app

      Timber::Probes::ActionController.insert!
      Timber::Probes::ActionView.insert!

      class UsersController < ActionController::Base
        layout nil

        def index
          render template: "template"
        end

        def method_for_action(action_name)
          action_name
        end
      end
    end

    after(:each) do
      reset_rails_app
      Object.send(:remove_const, :UsersController)
    end

    let(:controller_class) { UsersController }
    let(:controller) { controller_class.new }
    let(:request) { ActionDispatch::TestRequest.new('REQUEST_METHOD' => 'GET', 'rack.input' => '') }
    let(:request_context_class) { Timber::Contexts::ActionControllerRequest }
    let(:context_class) { Timber::Contexts::ActionViewTemplateRender }

    describe "#process_action" do
      it "should set the context" do
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(request_context_class), nil, nil).and_yield.once
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(context_class)).and_yield
        dispatch_rails_request(controller, :index)
      end
    end
  end
end
