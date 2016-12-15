require "spec_helper"

describe Timber::LogDevices::HTTP do
  # We have to define our own at_exit method, because the mocks and
  # everything are stripped out before. Otherwise it tries to issue
  # a request :(
  before(:each) do
    described_class.class_eval do
      def at_exit; true; end
    end
  end

  describe "#initialize" do
    it "should start a thread for delivery" do
      expect_any_instance_of(described_class).to receive(:deliver).at_least(1).times.and_return(true)
      http = described_class.new("MYKEY", frequency_seconds: 0.1)
      thread = http.instance_variable_get(:@delivery_interval_thread)
      expect(thread).to be_alive

      http.write("my log message")
      sleep 0.2 # too fast!
    end
  end

  describe "#write" do
    let(:http) { described_class.new("MYKEY") }
    let(:buffer) { http.instance_variable_get(:@buffer) }

    it "should buffer the messages" do
      http.write("test log message")
      expect(buffer.reserve).to eq("test log message")
    end

    context "with a low payload limit" do
      let(:http) { described_class.new("MYKEY", :payload_limit_bytes => 20) }

      it "should attempt a delivery when the payload limit is exceeded" do
        message = "a" * 19
        http.write(message)
        expect(http).to receive(:deliver).exactly(1).times.with(message)
        http.write("my log message")
      end
    end
  end

  describe "#close" do
    let(:http) { described_class.new("MYKEY") }

    it "should kill the delivery thread the messages" do
      http.close
      thread = http.instance_variable_get(:@delivery_interval_thread)
      sleep 0.1 # too fast!
      expect(thread).to_not be_alive
    end

    it "should attempt a delivery" do
      message = "a" * 19
      http.write(message)
      expect(http).to receive(:deliver).exactly(1).times.with(message)
      http.close
    end
  end

  # describe "#deliver" do
  #   let(:http) { described_class.new("MYKEY") }
  #   let(:buffer) { http.instance_variable_get(:@buffer) }

  #   after(:each) { http.close }

  #   it "should delivery properly and flush the buffer" do
  #     expect_any_instance_of(described_class).to receive(:at_exit).exactly(1).times.and_return(true)
  #     stub = stub_request(:post, "https://api.timber.io/http_frames").
  #       with(
  #         :body => "test log message",
  #         :headers => {'Authorization'=>'Basic TVlLRVk=', 'Connection'=>'keep-alive', 'Content-Type'=>'application/json', 'User-Agent'=>'Timber Ruby Gem/1.0.0'}
  #       ).
  #       to_return(:status => 200, :body => "", :headers => {})

  #     http.write("test log message")

  #     expect(buffer).to_not be_empty

  #     http.send(:deliver)

  #     expect(stub).to have_been_requested.times(1)
  #     expect(buffer).to be_empty
  #   end
  # end
end