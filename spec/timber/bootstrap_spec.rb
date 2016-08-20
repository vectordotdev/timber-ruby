require "spec_helper"

describe Timber::Bootstrap do
  describe ".bootstrap!" do
    let(:middleware) { Rack::Builder.new }
    let(:insert_before) { ::Rails::Rack::Logger }

    def self.it_should_not_bootstrap
      it "should not bootstrap" do
        expect(Timber::Probes).to_not receive(:insert!)
        expect(described_class.bootstrap!(middleware, insert_before)).to be false
      end
    end

    def self.it_should_bootstrap
      it "should bootstrap" do
        expect(Timber::Probes).to receive(:insert!).once
        expect(described_class.bootstrap!(middleware, insert_before)).to be true
      end
    end

    it_should_bootstrap

    context "disabled" do
      before(:each) { Timber::Config.enabled = false }
      after(:each) { Timber::Config.enabled = true }

      it_should_not_bootstrap
    end
  end
end
