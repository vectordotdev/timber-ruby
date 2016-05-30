require "spec_helper"

describe Timber::LogTruck::Delivery do
  describe "#deliver!" do
    context "with an application_id" do
      before(:each) { Timber::Config.application_id = 1234 }
      after(:each) { Timber::Config.application_id = nil }

      context "with an application_id" do
        before(:each) { Timber::Config.application_key = "key" }
        after(:each) { Timber::Config.application_key = nil }

        let(:log_line_hashes) { [{:message => "hello"}] }
        let(:delivery) { described_class.new(log_line_hashes) }
        let(:stub) {
          stub_request(:post, "https://timber-odin.herokuapp.com/agent_log_frames").
            with(:body => "[{\"message\":\"hello\"}]",
                 :headers => {'Content-Type'=>'application/json'})
        }

        before(:each) { stub }

        it "should delivery successfully" do
          delivery.deliver!
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
            expect { delivery.deliver! }.to raise_error(Timber::LogTruck::Delivery::DeliveryError)
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
            expect { delivery.deliver! }.to raise_error(Timber::LogTruck::Delivery::DeliveryError)
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
            expect { delivery.deliver! }.to raise_error(Timber::LogTruck::Delivery::DeliveryError)
          end
        end
      end
    end
  end
end
