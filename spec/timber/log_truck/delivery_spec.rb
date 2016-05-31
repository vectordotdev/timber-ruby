require "spec_helper"

describe Timber::LogTruck::Delivery do
  describe "#deliver!" do
    context "with an application_key" do
      def new_stub
        stub_request(:post, "https://timber-odin.herokuapp.com/agent_log_frames").
          with(:body => "{\"agent_log_frame\": {\"log_lines\": [{\"message\": \"hello\"}]}}",
               :headers => {'Content-Type'=>'application/json'})
      end

      before(:each) { Timber::Config.application_key = "key" }
      after(:each) { Timber::Config.application_key = nil }

      let(:log_line_jsons) { ["{\"message\": \"hello\"}"] }
      let(:delivery) { described_class.new(log_line_jsons) }
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
end
