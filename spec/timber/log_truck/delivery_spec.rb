require "spec_helper"

describe Timber::LogTruck::Delivery do
  describe "#deliver!" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }

    before(:each) { ActiveSupport.send(:silence_warnings) { described_class::RETRY_COUNT = 0 } }
    after(:each) { ActiveSupport.send(:silence_warnings) { described_class::RETRY_COUNT = 3 } }

    def new_stub
      stub_request(:post, "https://timber-odin.herokuapp.com/agent_log_frames").
        with(:body => "{\"agent_log_frame\": {\"log_lines\": [{\"dt\":\"2016-09-01T12:00:00.000000Z\",\"message\":\"hello\",\"context\":{\"_version\":1,\"hostname\":\"Bens-MBP.fios-router.home\",\"_index\":0},\"context_hierarchy\":[\"server\"]}]}}",
             :headers => {'Content-Type'=>'application/json'})
    end

    around(:each) do |example|
      Timecop.freeze(time) { example.run }
    end

    let(:log_lines) { [Timber::LogLine.new("hello")] }
    let(:delivery) { described_class.new(Timber::Config.application_key, log_lines) }
    let(:stub) { new_stub }

    before(:each) { stub }

    it "should delivery successfully" do
      delivery.deliver!
      expect(stub).to have_been_requested
    end

    context "timeout error" do
      let(:stub) {
        new_stub.to_timeout
      }

      it "should raise an error" do
        expect { delivery.deliver! }.to raise_error(Timber::LogTruck::Delivery::DeliveryError)
      end
    end

    context "random error" do
      let(:stub) {
        new_stub.to_raise(StandardError.new("some error"))
      }

      it "should raise an error" do
        expect { delivery.deliver! }.to raise_error(Timber::LogTruck::Delivery::DeliveryError)
      end
    end

    context "internal server error" do
      let(:stub) {
        new_stub.to_return(status: [500, "Internal Server Error"])
      }

      it "should raise an error" do
        expect { delivery.deliver! }.to raise_error(Timber::LogTruck::Delivery::DeliveryError)
      end
    end
  end
end
