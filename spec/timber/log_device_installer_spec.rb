require "spec_helper"

describe Timber::LogDeviceInstaller do
  describe Timber::LogDeviceInstaller::Collector do
    describe "#write" do
      let(:message) { "hello there" }
      let(:io) { StringIO.new }
      let(:logger) { Logger.new(io) }

      before(:each) { Timber::LogDeviceInstaller.install!(logger) }

      it "logs to the original source" do
        expect(io).to receive(:write).with(message).once
        logger << message
      end

      it "drops a log in the log yard" do
        expect(Timber::LogYard).to receive(:drop).with(kind_of(Timber::LogLine)).once
        logger << message
      end
    end
  end
end
