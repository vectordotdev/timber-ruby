require "spec_helper"

describe Timber::LogEntry, :rails_23 => true do
  describe "#to_msgpack" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }

    it "should encode properly with an event and context" do
      event = Timber::Events::Custom.new(type: :event_type, message: "event_message", data: {a: 1})
      context = {custom: Timber::Contexts::Custom.new(type: :context_type, data: {b: 1})}
      log_entry = described_class.new("INFO", time, nil, "log message", context, event)
      msgpack = log_entry.to_msgpack
      expect(msgpack).to eq("\x85\xA5level\xA4INFO\xA2dt\xBB2016-09-01T12:00:00.000000Z\xA7message\xABlog message\xA5event\x81\xAFserver_side_app\x81\xA6custom\x81\xAAevent_type\x81\xA1a\x01\xA7context\x81\xA6custom\x81\xACcontext_type\x81\xA1b\x01".force_encoding("ASCII-8BIT"))
    end
  end
end