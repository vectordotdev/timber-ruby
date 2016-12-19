require "spec_helper"

describe Timber::LogDevices::HTTP do
  describe "#initialize" do
    it "should start a intervaled flush thread and delivery" do
      http = described_class.new("MYKEY", flush_interval: 0.1)
      expect(http).to receive(:flush).at_least(1).times
      thread = http.instance_variable_get(:@flush_thread)
      expect(thread).to be_alive
      http.write("my log message")
      sleep 0.5 # too fast!
    end
  end

  describe "#write" do
    let(:http) { described_class.new("MYKEY") }
    let(:msg_queue) { http.instance_variable_get(:@msg_queue) }

    it "should buffer the messages" do
      http.write("test log message")
      expect(msg_queue.flush).to eq(["test log message"])
    end

    context "with a low batch byte size" do
      let(:http) { described_class.new("MYKEY", :batch_byte_size => 20) }

      it "should attempt a delivery when the payload limit is exceeded" do
        message = "a" * 19
        http.write(message)
        expect(http).to receive(:flush).exactly(1).times
        http.write("my log message")
      end
    end
  end

  describe "#close" do
    let(:http) { described_class.new("MYKEY") }

    it "should kill the threads" do
      http.close
      thread = http.instance_variable_get(:@flush_thread)
      sleep 0.1 # too fast!
      expect(thread).to_not be_alive
      thread = http.instance_variable_get(:@outlet_thread)
      sleep 0.1 # too fast!
      expect(thread).to_not be_alive
    end

    it "should attempt a delivery" do
      message = "a" * 19
      http.write(message)
      expect(http).to receive(:flush).exactly(1).times
      http.close
    end
  end

  # describe "#deliver" do
  #   let(:http) { described_class.new("MYKEY") }

  #   after(:each) { http.close }

  #   it "should delivery properly and flush the buffer" do
  #     stub = stub_request(:post, "https://logs.timber.io/frames").
  #       with(
  #         :body => "test log message",
  #         :headers => {
  #           'Authorization' => 'Basic TVlLRVk=',
  #           'Connection' => 'keep-alive',
  #           'Content-Type' => 'application/x-timber-msgpack-frame-1',
  #           'User-Agent' => "Timber Ruby Gem/#{Timber::VERSION}"
  #         }
  #       ).
  #       to_return(:status => 200, :body => "", :headers => {})

  #     http.write("test log message")
  #     buffer = http.instance_variable_get(:@buffer)
  #     buffers = buffer.instance_variable_get(:@buffers)
  #     expect(buffers.size).to eq(1)
  #     body = buffer.reserve
  #     thread = http.send(:deliver, body)
  #     thread.join

  #     expect(stub).to have_been_requested.times(1)
  #     expect(buffers.size).to eq(0)
  #   end
  # end
end