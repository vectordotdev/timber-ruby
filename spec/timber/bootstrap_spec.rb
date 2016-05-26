require "spec_helper"

describe Timber::Bootstrap do
  describe ".bootstrap!" do
    let(:logger) { Timber::Config.logger }

    it "should bootstrap properly" do
      expect(Timber::Probes).to receive(:insert!).once
      expect(Timber::LogDeviceInstaller).to receive(:install!).with(logger).once
      expect(Timber::LogTruck).to receive(:start).once
      described_class.bootstrap!(logger)
    end
  end
end
