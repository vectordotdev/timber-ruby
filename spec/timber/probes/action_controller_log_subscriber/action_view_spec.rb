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

  let(:logger_context_class) { Timber::Contexts::Logger }
  let(:rack_request_context_class) { Timber::Contexts::HTTPRequests::Rack }
  let(:request_context_class) { Timber::Contexts::HTTPRequests::ActionControllerSpecific }
  let(:organization_context_class) { Timber::Contexts::Organizations::ActionController }
  let(:user_context_class) { Timber::Contexts::Users::ActionController }
  let(:response_context_class) { Timber::Contexts::HTTPResponses::ActionController }
  let(:action_view_context_class) { Timber::Contexts::TemplateRenders::ActionView }
  let(:action_view_specific_context_class) { Timber::Contexts::TemplateRenders::ActionViewSpecific }

  describe "#process_action" do
    it "should set the context" do
      allow(Timber::CurrentContext).to receive(:add).with(kind_of(logger_context_class))
      expect(Timber::CurrentContext).to receive(:add).with(kind_of(rack_request_context_class)).and_yield.once
      expect(Timber::CurrentContext).to receive(:add).with(kind_of(request_context_class), kind_of(organization_context_class), kind_of(user_context_class), kind_of(response_context_class)).and_yield.once
      expect(Timber::CurrentContext).to receive(:add).with(kind_of(action_view_context_class), kind_of(action_view_specific_context_class)).and_yield.once
      dispatch_rails_request("/users")
    end
  end
end
