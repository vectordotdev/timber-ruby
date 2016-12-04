require "spec_helper"

describe Timber::Probes::RackHTTPContext do
  describe described_class::Middleware do
    before(:each) do
      class PagesPlainController < ActionController::Base
        layout nil

        def index
          render json: {}
        end

        def method_for_action(action_name)
          action_name
        end
      end

      ::RailsApp.routes.draw do
        get 'pages_plain' => 'pages_plain#index'
      end
    end

    after(:each) do
      Object.send(:remove_const, :PagesPlainController)
    end

    let(:http_context_class) { Timber::Contexts::HTTP }

    describe "#process" do
      it "should set the context" do
        allow(Timber::CurrentContext).to receive(:with).with(:http, kind_of(http_context_class))
        dispatch_rails_request("/pages_plain")
      end
    end
  end
end