require "spec_helper"

describe Timber::Bootstrap do
  describe ".bootstrap!" do
    let(:middleware) { Rack::Builder.new }
    let(:insert_before) { ::Rails::Rack::Logger }

    def self.it_should_not_bootstrap
      it "should not bootstrap" do
        expect(Timber::Probes).to_not receive(:insert!)
        expect(Timber::LogTruck).to_not receive(:start)
        expect(described_class.bootstrap!(middleware, insert_before)).to be false
      end
    end

    def self.it_should_bootstrap
      it "should bootstrap" do
        expect(Timber::Probes).to receive(:insert!).once
        expect(Timber::LogTruck).to receive(:start!).once
        expect(described_class.bootstrap!(middleware, insert_before)).to be true
      end
    end

    context "log truck enabled" do
      before(:each) { Timber::Config.log_truck_enabled = true }
      after(:each) { Timber::Config.log_truck_enabled = false }

      it_should_bootstrap

      context "without an application_key" do
        before(:each) do
          @old_application_key = Timber::Config.application_key
          Timber::Config.application_key = nil
        end
        after(:each) { Timber::Config.application_key = @old_application_key }

        it_should_not_bootstrap
      end

      context "disabled" do
        before(:each) { Timber::Config.enabled = false }
        after(:each) { Timber::Config.enabled = true }

        it_should_not_bootstrap
      end
    end
  end
end
