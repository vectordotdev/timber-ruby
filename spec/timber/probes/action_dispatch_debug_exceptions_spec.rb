require "spec_helper"

describe Timber::Probes::ActionDispatchDebugExceptions do
  describe described_class::InstanceMethods do
    describe ".log_error" do
      before(:each) do
        class ExceptionController < ActionController::Base
          layout nil

          def index
            raise "boom"
          end

          def method_for_action(action_name)
            action_name
          end
        end

        ::RailsApp.routes.draw do
          get 'exception' => 'exception#index'
        end
      end

      after(:each) do
        Object.send(:remove_const, :ExceptionController)
      end

      let(:rack_request_context_class) { Timber::Contexts::HTTPRequests::Rack }
      let(:request_context_class) { Timber::Contexts::HTTPRequests::ActionControllerSpecific }
      let(:organization_context_class) { Timber::Contexts::Organizations::ActionController }
      let(:user_context_class) { Timber::Contexts::Users::ActionController }
      let(:response_context_class) { Timber::Contexts::HTTPResponses::ActionController }
      let(:exception_context_class) { Timber::Contexts::Exception }

      it "should set the context" do
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(rack_request_context_class)).and_yield.once
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(request_context_class), kind_of(organization_context_class), kind_of(user_context_class), kind_of(response_context_class)).and_yield.once
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(exception_context_class)).and_yield
        dispatch_rails_request("/exception")
      end
    end
  end
end
