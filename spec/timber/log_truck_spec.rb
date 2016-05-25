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
    let(:stub) {
      stub_request(:post, "https://timber-odin.herokuapp.com/").
        with(:body => "[{\"message\":\"hello\"}]",
             :headers => {'Content-Type'=>'application/json'})
    }

    before(:each) { stub }

    it "should delivery successfully" do
      log_truck.deliver!
      expect(stub).to have_been_requested
    end

    context "timeout error" do
      let(:stub) {
        stub_request(:post, "https://timber-odin.herokuapp.com/").
          with(:body => "[{\"message\":\"hello\"}]",
               :headers => {'Content-Type'=>'application/json'}).
          to_timeout
      }

      it "should raise an error" do
        expect { log_truck.deliver! }.to raise_error(Timber::LogTruck::DeliveryError)
      end
    end

    context "random error" do
      let(:stub) {
        stub_request(:post, "https://timber-odin.herokuapp.com/").
          with(:body => "[{\"message\":\"hello\"}]",
               :headers => {'Content-Type'=>'application/json'}).
          to_raise(StandardError.new("some error"))
      }

      it "should raise an error" do
        expect { log_truck.deliver! }.to raise_error(Timber::LogTruck::DeliveryError)
      end
    end

    context "internal server error" do
      let(:stub) {
        stub_request(:post, "https://timber-odin.herokuapp.com/").
          with(:body => "[{\"message\":\"hello\"}]",
               :headers => {'Content-Type'=>'application/json'}).
          to_return(status: [500, "Internal Server Error"])
      }

      it "should raise an error" do
        expect { log_truck.deliver! }.to raise_error(Timber::LogTruck::DeliveryError)
      end
    end
  end
end
