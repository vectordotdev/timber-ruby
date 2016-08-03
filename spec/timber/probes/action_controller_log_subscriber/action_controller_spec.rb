require "spec_helper"

describe Timber::Probes::ActiveSupportLogSubscriber::ActionController do
  before(:each) do
    class PagesController < ActionController::Base
      layout nil

      def index
        response.headers['Content-Length'] = "500"
        raise Timber::CurrentContext.snapshot.to_json.inspect
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

  let(:response_context_class) { Timber::Contexts::ActionControllerResponse }

  describe "#process_action" do
    it "should set the context" do
      #expect_any_instance_of(response_context_class).to receive(:event=).with(kind_of(ActiveSupport::Notifications::Event)).once
      dispatch_rails_request("/pages")
    end
  end
end
