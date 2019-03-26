require "spec_helper"

describe Timber::LogEntry do
  let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }

  describe "#to_msgpack" do
    it "should encode properly with an event and context" do
      event = {
        message: "event_message",
        event: {
          event_type: {
            a: 1
          }
        }
      }
      context = {custom: {a: "b"}}
      log_entry = described_class.new("INFO", time, nil, "log message", context, event)
      msgpack = log_entry.to_msgpack
      expect(msgpack).to start_with("\x85\xA5level\xA4INFO\xA2dt\xBB2016-09-01T12:00:00.000000Z".force_encoding("ASCII-8BIT"))
    end
  end
end
