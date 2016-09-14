require "spec_helper"

describe Timber::Contexts::Users::ActionController do
  around(:each) do |example|
    class PagesController < ActionController::Base
      layout nil

      def index
        render json: {}
      end

      def method_for_action(action_name)
        action_name
      end

      private
        def current_user
          # I want this to execute a query and test logging that query
          @user ||= User.first
        end
    end

    example.run

    Object.send(:remove_const, :PagesController)

    Timber::Probes::ActiveSupportLogSubscriber.insert!
  end

  let(:context) { described_class.new(PagesController.new) }

  describe "#email" do
    subject { context.email }
    it { should be_nil }

    context "with a user" do
      before(:each) { User.create!(email: "a@a.com") }
      it { should eq("a@a.com") }

      context "with a user context" do
        around(:each) do |example|
          Timber::CurrentContext.add(context) do
            example.run
          end
        end

        it { should eq("a@a.com") }

        context "with a debug log level" do
          around(:each) do |example|
            old_level = ::Rails.logger.level
            ::Rails.logger.level = ::Logger::DEBUG
            example.run
            ::Rails.logger.level = old_level
          end

          # If the user object is not cached, it will create an infinite loop.
          # This is because getting the user executes a query, which in turn creates
          # logs, with tries to grab the user again, etc.
          it { should eq("a@a.com") }
        end
      end
    end
  end
end