require 'spec_helper'

describe Timber::Frameworks::Rails do
  describe described_class::Railtie do
    around(:each) { |example| with_rails_app(example) }

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
end
