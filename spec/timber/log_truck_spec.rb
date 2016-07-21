require "spec_helper"

describe Timber::LogTruck do
  describe ".start!" do
    it "spawns a new thread" do
      expect(Thread).to receive(:new).once
      described_class.start!
    end

    it "delivers" do
      expect(described_class).to receive(:deliver).once
      described_class.start! do |thread|
        thread.kill
      end.join
    end
  end

  describe ".deliver" do
    let(:log_pile) { Timber::LogPile.get(Timber::Config.application_key) }

    it "doesn't deliver because there is nothing to deliver" do
      expect(log_pile).to_not receive(:deliver)
      described_class.deliver
    end

    context "with a log pile" do
      before(:each) do
        log_line = Timber::LogLine.new("this is a log line")
        log_pile.drop(log_line)
      end

      it "delivers once and empties the log pile" do
        expect(log_pile.size).to eq(1)
        expect_any_instance_of(described_class).to receive(:deliver!).once
        described_class.deliver
        expect(log_pile.size).to eq(0)
      end
    end
  end

  describe "#initialize" do
    let(:log_lines) { [] }
    let(:log_truck) { described_class.new(Timber::Config.application_key, log_lines) }
    subject { log_truck }

    it "should raise an exception" do
      expect { subject }.to raise_exception(Timber::LogTruck::NoPayloadError)
    end

    context "with log lines" do
      let(:log_lines) { [Timber::LogLine.new("hello")] }
      its(:log_lines) { should eq(log_lines) }
    end
  end

  describe "#deliver!" do
    let(:log_lines) { [Timber::LogLine.new("hello")] }
    let(:log_truck) { described_class.new(Timber::Config.application_key, log_lines) }

    it "should delivery successfully" do
      expect_any_instance_of(Timber::LogTruck::Delivery).to receive(:deliver!)
      log_truck.deliver!
    end
  end
end
