require "spec_helper"

# Note: these tests access instance variables and private methods as a means of
# not muddying the public API. This object should expose a simple buffer like
# API, tests should not alter that.
describe Timber::LogDevices::HTTP do
  describe "#initialize" do
    it "should initialize properly" do
      http = described_class.new("MYKEY", flush_interval: 0.1)

      # Ensure that threads have not started
      thread = http.instance_variable_get(:@flush_thread)
      expect(thread).to be_nil
      thread = http.instance_variable_get(:@request_outlet_thread)
      expect(thread).to be_nil
    end
  end

  describe "#write" do
    let(:http) { described_class.new("MYKEY") }
    let(:msg_queue) { http.instance_variable_get(:@msg_queue) }

    it "should buffer the messages" do
      http.write("test log message")
      expect(msg_queue.flush).to eq(["test log message"])
      http.close
    end

    it "should start the flush threads" do
      http.write("test log message")

      thread = http.instance_variable_get(:@flush_thread)
      expect(thread).to be_alive
      thread = http.instance_variable_get(:@request_outlet_thread)
      expect(thread).to be_alive
      expect(http).to receive(:flush).exactly(1).times
      http.close
    end

    context "with a low batch size" do
      let(:http) { described_class.new("MYKEY", :batch_size => 2) }

      it "should attempt a delivery when the limit is exceeded" do
        http.write("test")
        expect(http).to receive(:flush_async).exactly(1).times
        http.write("my log message")
        expect(http).to receive(:flush).exactly(1).times
        http.close
      end
    end
  end

  describe "#close" do
    let(:http) { described_class.new("MYKEY") }

    it "should kill the threads" do
      http.send(:ensure_flush_threads_are_started)
      http.close
      thread = http.instance_variable_get(:@flush_thread)
      sleep 0.1 # too fast!
      expect(thread).to_not be_alive
      thread = http.instance_variable_get(:@request_outlet_thread)
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

  # Testing a private method because it helps break down our tests
  describe "#flush" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }

    it "should deliver the request" do
      http = described_class.new("MYKEY", flush_continuously: false)
      log_entry = Timber::LogEntry.new("INFO", time, nil, "test log message 1", nil, nil)
      http.write(log_entry)
      log_entry = Timber::LogEntry.new("INFO", time, nil, "test log message 2", nil, nil)
      http.write(log_entry)
      expect(http).to receive(:flush_async).exactly(2).times
      http.send(:flush)
      http.close
    end
  end

  # Testing a private method because it helps break down our tests
  describe "#flush_async" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }

    it "should add a request to the queue" do
      http = described_class.new("MYKEY", flush_continuously: false)
      log_entry = Timber::LogEntry.new("INFO", time, nil, "test log message 1", nil, nil)
      http.write(log_entry)
      log_entry = Timber::LogEntry.new("INFO", time, nil, "test log message 2", nil, nil)
      http.write(log_entry)
      http.send(:flush_async)
      request_queue = http.instance_variable_get(:@request_queue)
      request_attempt = request_queue.deq
      expect(request_attempt.request).to be_kind_of(Net::HTTP::Post)
      expect(request_attempt.request.body).to start_with("\x92\x83\xA5level\xA4INFO\xA2dt\xBB2016-09-01T12:00:00.000000Z\xA7message\xB2test log message 1".force_encoding("ASCII-8BIT"))

      message_queue = http.instance_variable_get(:@msg_queue)
      expect(message_queue.size).to eq(0)
    end
  end

  # Testing a private method because it helps break down our tests
  describe "#intervaled_flush" do
    it "should start a intervaled flush thread and flush on an interval" do
      http = described_class.new("MYKEY", flush_interval: 0.1)
      http.send(:ensure_flush_threads_are_started)
      expect(http).to receive(:flush_async).at_least(3).times
      sleep 1.1 # iterations check every 0.5 seconds
      http.close
    end
  end

  # Outlet
  describe "#request_outlet" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }

    it "should deliver requests on an interval" do
      stub = stub_request(:post, "https://logs.timber.io/sources/MY_SOURCE/frames").
        with(
          :body => start_with("\x92\x83\xA5level\xA4INFO\xA2dt\xBB2016-09-01T12:00:00.000000Z\xA7message\xB2test log message 1".force_encoding("ASCII-8BIT")),
          :headers => {
            'Authorization' => 'Bearer MYKEY',
            'Content-Type' => 'application/msgpack',
            'User-Agent' => "Timber Ruby/#{Timber::VERSION} (HTTP)"
          }
        ).
        to_return(:status => 200, :body => "", :headers => {})

      http = described_class.new("MYKEY", "MY_SOURCE", flush_interval: 0.1)
      log_entry1 = Timber::LogEntry.new("INFO", time, nil, "test log message 1", nil, nil)
      http.write(log_entry1)
      log_entry2 = Timber::LogEntry.new("INFO", time, nil, "test log message 2", nil, nil)
      http.write(log_entry2)
      sleep 2

      expect(stub).to have_been_requested.times(1)

      http.close
    end

    it "should support legacy API keys" do
      stub = stub_request(:post, "https://logs.timber.io/frames").
        with(
          :body => start_with("\x92\x83\xA5level\xA4INFO\xA2dt\xBB2016-09-01T12:00:00.000000Z\xA7message\xB2test log message 1".force_encoding("ASCII-8BIT")),
          :headers => {
            'Authorization' => 'Basic TVlLRVk=',
            'Content-Type' => 'application/msgpack',
            'User-Agent' => "Timber Ruby/#{Timber::VERSION} (HTTP)"
          }
        ).
        to_return(:status => 200, :body => "", :headers => {})

      http = described_class.new("MYKEY", flush_interval: 0.1)
      log_entry1 = Timber::LogEntry.new("INFO", time, nil, "test log message 1", nil, nil)
      http.write(log_entry1)
      log_entry2 = Timber::LogEntry.new("INFO", time, nil, "test log message 2", nil, nil)
      http.write(log_entry2)
      sleep 2

      expect(stub).to have_been_requested.times(1)

      http.close
    end
  end

  describe "#deliver_requests" do
    it "should handle exceptions properly and return" do
      allow_any_instance_of(Net::HTTP).to receive(:request).and_raise("boom")

      http_device = described_class.new("MYKEY", flush_continuously: false)
      req_queue = http_device.instance_variable_get(:@request_queue)

      # Place a request on the queue
      request = Net::HTTP::Post.new("/")
      request_attempt = Timber::LogDevices::HTTP::RequestAttempt.new(request)
      request_attempt.attempted!
      req_queue.enq(request_attempt)

      # Start a HTTP connection to test the method directly
      http = http_device.send(:build_http)
      http.start do |conn|
        result = http_device.send(:deliver_requests, conn)
        expect(result).to eq(false)
      end

      expect(req_queue.size).to eq(1)

      # Start a HTTP connection to test the method directly
      http = http_device.send(:build_http)
      http.start do |conn|
        result = http_device.send(:deliver_requests, conn)
        expect(result).to eq(false)
      end

      # Ensure the request gets discards after 3 attempts
      expect(req_queue.size).to eq(0)
    end
  end
end