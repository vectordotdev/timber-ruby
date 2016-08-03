require "spec_helper"

describe Timber::Probes::ActiveSupportLogSubscriber::ActionView do
  before(:each) do
    class UsersController < ActionController::Base
      layout nil

      def index
        render template: "template"
      end

      def method_for_action(action_name)
        action_name
      end
    end

    ::RailsApp.routes.draw do
      get 'users' => 'users#index'
    end
  end

  after(:each) do
    Object.send(:remove_const, :UsersController)
  end

  let(:rack_request_context_class) { Timber::Contexts::RackRequest }
  let(:request_context_class) { Timber::Contexts::ActionControllerRequest }
  let(:organization_context_class) { Timber::Contexts::ActionControllerOrganization }
  let(:user_context_class) { Timber::Contexts::ActionControllerUser }
  let(:response_context_class) { Timber::Contexts::ActionControllerResponse }
  let(:context_class) { Timber::Contexts::ActionViewTemplateRender }

  describe "#process_action" do
    it "should set the context" do
      expect(Timber::CurrentContext).to receive(:add).with(kind_of(rack_request_context_class)).and_yield.once
      expect(Timber::CurrentContext).to receive(:add).with(kind_of(request_context_class), kind_of(organization_context_class), kind_of(user_context_class), kind_of(response_context_class)).and_yield.once
      expect(Timber::CurrentContext).to receive(:add).with(kind_of(context_class)).and_yield.once
      dispatch_rails_request("/users")
    end
  end
end
