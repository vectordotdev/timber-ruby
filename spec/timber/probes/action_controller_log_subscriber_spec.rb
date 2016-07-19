require "spec_helper"

describe Timber::Probes::ActionControllerLogSubscriber do
  describe described_class::InstanceMethods do
    before(:each) do
      class PagesController < ActionController::Base
        layout nil

        def index
          response.headers['Content-Length'] = "500"
          render json: {}
        end

        def method_for_action(action_name)
          action_name
        end
      end

      ::RailsApp.routes.draw do
        get 'pages' => 'pages#index'
      end
    end

    after(:each) do
      Object.send(:remove_const, :PagesController)
    end

    let(:rack_request_context_class) { Timber::Contexts::RackRequest }
    let(:request_context_class) { Timber::Contexts::ActionControllerRequest }
    let(:response_context_class) { Timber::Contexts::ActionControllerResponse }

    describe "#process_action" do
      it "should set the context" do
        expect(Timber::CurrentContext.instance).to receive(:add).with(kind_of(rack_request_context_class)).and_yield.once
        expect(Timber::CurrentContext.instance).to receive(:add).with(kind_of(request_context_class), nil, nil).and_yield.once
        expect(Timber::CurrentContext.instance).to receive(:add).with(kind_of(response_context_class)).and_yield.once
        dispatch_rails_request("/pages")
      end
    end
  end
end
