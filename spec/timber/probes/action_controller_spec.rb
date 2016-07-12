require "spec_helper"

describe Timber::Probes::ActionController do
  describe Timber::Probes::ActionController::InstanceMethods do
    def dispatch(action)
      if controller.method(:dispatch).arity == 3
        controller.dispatch(action, request, ActionDispatch::TestResponse.new)
      else
        controller.dispatch(action, request)
      end
    end

    before(:each) do
      setup_rails_app
      initialize_rails_app

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
      reset_rails_app
      Object.send(:remove_const, :UsersController)
    end

    let(:controller_class) { UsersController }
    let(:controller) { controller_class.new }
    let(:request) do
      ActionDispatch::TestRequest.new('REQUEST_METHOD' => 'GET', 'rack.input' => '')
    end
    let(:request_context_class) { Timber::Contexts::ActionControllerRequest }

    describe "#process_action" do
      it "should set the context" do
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(request_context_class), nil, nil).and_yield.once
        dispatch(:index)
      end

      context "with a current_organization method" do
        before(:each) do
          class Organization
            attr_accessor :id, :name
          end

          class UsersController < ActionController::Base
            private
              def current_organization
                @current_organization ||= Organization.new.tap do |u|
                  u.id = 1
                  u.name = "My Organization"
                end
              end
          end
        end

        after(:each) do
          Object.send(:remove_const, :Organization)
        end

        let(:organization_context_class) { Timber::Contexts::ActionControllerOrganization }

        it "should set the context" do
          expect(Timber::CurrentContext).to receive(:add).with(kind_of(request_context_class), kind_of(organization_context_class), nil).and_yield.once
          dispatch(:index)
        end
      end

      context "with a current_user method" do
        before(:each) do
          class User
            attr_accessor :email, :id, :name
          end

          class UsersController < ActionController::Base
            private
              def current_user
                @current_user ||= User.new.tap do |u|
                  u.email = "bob@doe.com"
                  u.id = 1
                  u.name = "Bob Doe"
                end
              end
          end
        end

        after(:each) do
          Object.send(:remove_const, :User)
        end

        let(:user_context_class) { Timber::Contexts::ActionControllerUser }

        it "should set the context" do
          expect(Timber::CurrentContext).to receive(:add).with(kind_of(request_context_class), nil, kind_of(user_context_class)).and_yield.once
          dispatch(:index)
        end
      end
    end
  end
end
