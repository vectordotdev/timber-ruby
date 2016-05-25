require "spec_helper"

describe Timber::LogTruck do
  describe ".start" do
    let(:pid) { described_class.start! }

    it "spawns a new thread" do
      expect(Thread).to receive(:new).once
      described_class.start
    end

    it "doesn't deliver because there is nothing to deliver" do
      expect_any_instance_of(described_class).to_not receive(:deliver!)
      described_class.start
    end

    context "with a log pile" do
      before(:each) do
        log_line = Timber::LogLine.new("this is a log line")
        Timber::LogPile.drop(log_line)
      end

      it "delivers once" do
        expect_any_instance_of(described_class).to receive(:deliver!).once
        described_class.start do |thread|
          thread.kill
        end.join
      end
    end
  end

  describe "#initialize" do
    let(:log_line_hashes) { [] }
    let(:log_truck) { described_class.new(log_line_hashes) }
    subject { log_truck }

    it "should raise an exception" do
      expect { subject }.to raise_exception(Timber::LogTruck::NoPayloadError)
    end

    context "with a log pile" do
      let(:log_line_hashes) { [{:message => "hello"}] }
      its(:log_line_hashes) { should eq(log_line_hashes) }
    end
  end

  describe "#deliver!" do
    let(:log_line_hashes) { [{:message => "hello"}] }
    let(:log_truck) { described_class.new(log_line_hashes) }
    subject { log_truck.deliver! }

    it "makes a POST call to the timber API" do
      stub = stub_request(:post, "https://timber-odin.herokuapp.com/").
         with(:body => "[{\"message\":\"hello\"}]",
              :headers => {'Content-Type'=>'application/json'})
      subject
      expect(stub).to have_been_requested
    end
  end
end
