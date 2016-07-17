require "spec_helper"

describe Timber::Probes::ActionControllerBase do
  describe described_class::InstanceMethods do
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

    let(:rack_request_context_class) { Timber::Contexts::RackRequest }
    let(:request_context_class) { Timber::Contexts::ActionControllerRequest }

    describe "#process_action" do
      it "should set the context" do
        expect(Timber::CurrentContext.instance).to receive(:add).with(kind_of(rack_request_context_class)).and_yield.once
        expect(Timber::CurrentContext.instance).to receive(:add).with(kind_of(request_context_class), nil, nil).and_yield.once
        dispatch_rails_request("/pages_plain")
      end

      context "with a current_organization method" do
        before(:each) do
          class Organization
            attr_accessor :id, :name
          end

          class PagesWithOrganizationController < ActionController::Base
            layout nil

            def index
              render template: "template"
            end

            private
              def method_for_action(action_name)
                action_name
              end

              def current_organization
                @current_organization ||= Organization.new.tap do |u|
                  u.id = 1
                  u.name = "My Organization"
                end
              end
          end

          ::RailsApp.routes.draw do
            get 'pages_with_organization' => 'pages_with_organization#index'
          end
        end

        after(:each) do
          Object.send(:remove_const, :Organization)
          Object.send(:remove_const, :PagesWithOrganizationController)
        end

        let(:organization_context_class) { Timber::Contexts::ActionControllerOrganization }

        it "should set the context" do
          expect(Timber::CurrentContext).to receive(:add).with(kind_of(rack_request_context_class)).and_yield.once
          expect(Timber::CurrentContext).to receive(:add).with(kind_of(request_context_class), kind_of(organization_context_class), nil).and_yield.once
          dispatch_rails_request("/pages_with_organization")
        end
      end

      context "with a current_user method" do
        before(:each) do
          class User
            attr_accessor :email, :id, :name
          end

          class PagesWithUserController < ActionController::Base
            layout nil

            def index
              render template: "template"
            end

            private
              def method_for_action(action_name)
                action_name
              end

              def current_user
                @current_user ||= User.new.tap do |u|
                  u.email = "bob@doe.com"
                  u.id = 1
                  u.name = "Bob Doe"
                end
              end
          end

          ::RailsApp.routes.draw do
            get 'pages_with_user' => 'pages_with_user#index'
          end
        end

        after(:each) do
          Object.send(:remove_const, :User)
          Object.send(:remove_const, :PagesWithUserController)
        end

        let(:user_context_class) { Timber::Contexts::ActionControllerUser }

        it "should set the context" do
          expect(Timber::CurrentContext).to receive(:add).with(kind_of(rack_request_context_class)).and_yield.once
          expect(Timber::CurrentContext).to receive(:add).with(kind_of(request_context_class), nil, kind_of(user_context_class)).and_yield.once
          dispatch_rails_request("/pages_with_user")
        end
      end
    end
  end
end
