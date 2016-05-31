require "spec_helper"

describe Timber::LogTruck do
  describe ".start!" do
    it "spawns a new thread" do
      expect(Thread).to receive(:new).once
      described_class.start!
    end

    it "delivers" do
      expect(described_class).to receive(:deliver!).once
      described_class.start! do |thread|
        thread.kill
      end.join
    end
  end

  describe ".deliver!" do
    it "doesn't deliver because there is nothing to deliver" do
      expect_any_instance_of(described_class).to_not receive(:deliver!)
      described_class.deliver!
    end

    context "with a log pile" do
      before(:each) do
        log_line = Timber::LogLine.new("this is a log line")
        Timber::LogPile.drop(log_line)
      end

      it "delivers once and empties the log pile" do
        expect(Timber::LogPile.size).to eq(1)
        expect_any_instance_of(described_class).to receive(:deliver!).once
        described_class.deliver!
        expect(Timber::LogPile.size).to eq(0)
      end
    end
  end

  describe "#initialize" do
    let(:log_line_jsons) { [] }
    let(:log_truck) { described_class.new(log_line_jsons) }
    subject { log_truck }

    it "should raise an exception" do
      expect { subject }.to raise_exception(Timber::LogTruck::NoPayloadError)
    end

    context "with a log pile" do
      let(:log_line_jsons) { ["{\"message\": \"hello\"}"] }
      its(:log_line_jsons) { should eq(log_line_jsons) }
    end
  end

  describe "#deliver!" do
    let(:log_line_jsons) { ["{\"message\": \"hello\"}"] }
    let(:log_truck) { described_class.new(log_line_jsons) }

    it "should delivery successfully" do
      expect_any_instance_of(Timber::LogTruck::Delivery).to receive(:deliver!)
      log_truck.deliver!
    end
  end
end
