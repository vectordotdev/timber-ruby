require "spec_helper"

describe Timber::Contexts::Organizations::ActionController do
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
        def current_organization
          # I want this to execute a query and test logging that query
          Organization.first
        end
    end

    example.run

    Object.send(:remove_const, :PagesController)
  end

  let(:context) { described_class.new(PagesController.new) }

  describe "#name" do
    subject { context.name }
    it { should be_nil }

    context "with an organization" do
      before(:each) { Organization.create!(name: "Timber") }
      it { should eq("Timber") }

      context "with an organization context" do
        around(:each) do |example|
          Timber::CurrentContext.add(context) do
            example.run
          end
        end

        it { should eq("Timber") }
      end
    end
  end
end