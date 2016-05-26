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
      it_should_not_bootstrap

      context "with an application_key" do
        before(:each) { Timber::Config.application_key = "1234" }

        it "should bootstrap properly" do
          expect(Timber::Probes).to receive(:insert!).once
          expect(Timber::LogDeviceInstaller).to receive(:install!).with(logger).once
          expect(Timber::LogTruck).to receive(:start!).once
          expect(described_class.bootstrap!(logger)).to be true
        end

        context "disabled" do
          before(:each) { Timber::Config.enabled = false }
          it_should_not_bootstrap
        end
      end
    end
  end
end
