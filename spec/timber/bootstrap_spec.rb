require "spec_helper"

describe Timber::Bootstrap do
  describe ".bootstrap!" do
    let(:logger) { Timber::Config.logger }

    def self.it_should_not_bootstrap
      it "should not bootstrap" do
        expect(Timber::Probes).to_not receive(:insert!)
        expect(Timber::LogDeviceInstaller).to_not receive(:install!)
        expect(Timber::LogTruck).to_not receive(:start)
        expect(described_class.bootstrap!(logger)).to be false
      end
    end

    it_should_not_bootstrap

    context "with an application_id" do
      before(:each) { Timber::Config.application_id = 123 }
      after(:each) { Timber::Config.application_id = nil }
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

        it "should bootstrap properly" do
          expect(Timber::Probes).to receive(:insert!).once
          expect(Timber::LogDeviceInstaller).to receive(:install!).with(logger).once
          expect(Timber::LogTruck).to receive(:start!).once
          expect(described_class.bootstrap!(logger)).to be true
        end

        context "disabled" do
          before(:each) { Timber::Config.enabled = false }
          after(:each) { Timber::Config.enabled = true }
          it_should_not_bootstrap
        end
      end
    end
  end
end
