require 'spec_helper'

describe Timber::Frameworks::Rails::Railtie do
  after(:each) do
    reset_rails_app
  end

  describe "initializer" do
    context "with an application_key" do
      before(:each) { Timber::Config.application_key = "key" }
      after(:each) { Timber::Config.application_key = nil }

      it "bootstraps" do
        expect(Timber::Bootstrap).to receive(:bootstrap!).once
        initialize_rails_app
      end
    end
  end
end
