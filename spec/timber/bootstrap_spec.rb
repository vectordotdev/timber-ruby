require "spec_helper"

describe Timber::Bootstrap do
  describe ".bootstrap!" do
    let(:logger) { Timber::Config.logger }
    let(:middleware) { Rack::Builder.new }
    let(:insert_before) { ::Rails::Rack::Logger }

    def self.it_should_not_bootstrap
      it "should not bootstrap" do
        expect(Timber::Probes).to_not receive(:insert!)
        expect(Timber::LogDeviceInstaller).to_not receive(:install!)
        expect(Timber::LogTruck).to_not receive(:start)
        expect(described_class.bootstrap!(logger, middleware, insert_before)).to be false
      end
    end

    def self.it_should_bootstrap
      it "should bootstrap" do
        expect(Timber::Probes).to receive(:insert!).once
        expect(Timber::LogDeviceInstaller).to receive(:install!).with(logger).once
        expect(Timber::LogTruck).to receive(:start!).once
        expect(described_class.bootstrap!(logger, middleware, insert_before)).to be true
      end
    end

    it_should_not_bootstrap

    context "with an application_key" do
      before(:each) do
        Timber::Config.application_key = "1234"
        Timber::Config.log_truck_enabled = true
      end

      after(:each) do
        Timber::Config.application_key = nil
        Timber::Config.log_truck_enabled = false
      end

      it_should_bootstrap

      context "disabled" do
        before(:each) { Timber::Config.enabled = false }
        after(:each) { Timber::Config.enabled = true }
        it_should_not_bootstrap
      end
    end
  end
end
