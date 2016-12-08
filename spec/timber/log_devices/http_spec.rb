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
      expect_any_instance_of(described_class).to receive(:at_exit).exactly(1).times.and_return(true)
      expect_any_instance_of(described_class).to receive(:deliver).exactly(2).times.and_return(true)
      http = described_class.new("MYKEY", frequency_seconds: 0.1)
      thread = http.instance_variable_get(:@delivery_thread)
      expect(thread).to be_alive
      sleep 0.25 # allow 2 iterations
      http.close
    end
  end

  describe "#write" do
    let(:http) { described_class.new("MYKEY") }
    let(:buffer) { http.instance_variable_get(:@buffer) }

    after(:each) { http.close }

    it "should buffer the messages" do
      http.write("test log message")
      expect(buffer.read).to eq("test log message")
    end
  end

  describe "#deliver" do
    let(:http) { described_class.new("MYKEY") }
    let(:buffer) { http.instance_variable_get(:@buffer) }

    after(:each) { http.close }

    it "should delivery properly and flush the buffer" do
      expect_any_instance_of(described_class).to receive(:at_exit).exactly(1).times.and_return(true)
      stub = stub_request(:post, "https://api.timber.io/http_frames").
        with(
          :body => "test log message",
          :headers => {'Authorization'=>'Basic TVlLRVk=', 'Connection'=>'keep-alive', 'Content-Type'=>'application/json', 'User-Agent'=>'Timber Ruby Gem/1.0.0'}
        ).
        to_return(:status => 200, :body => "", :headers => {})

      http.write("test log message")

      expect(buffer).to_not be_empty

      http.send(:deliver)

      expect(stub).to have_been_requested.times(1)
      expect(buffer).to be_empty
      http.close
    end
  end
end