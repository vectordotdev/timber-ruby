require "spec_helper"

describe Timber::LogEntry, :rails_23 => true do
  let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }

  describe "#to_json" do
    it "should handle encoding issues" do
      message = 'http://www.metrojobb.se/jobb/1013893-skadeadministratör'.force_encoding('ASCII-8BIT')
      log_entry = described_class.new("INFO", time, nil, message, nil, nil)
    end
  end

  describe "#to_msgpack" do
    it "should encode properly with an event and context" do
      event = Timber::Events::Custom.new(type: :event_type, message: "event_message", data: {a: 1})
      context = {custom: Timber::Contexts::Custom.new(type: :context_type, data: {b: 1})}
      log_entry = described_class.new("INFO", time, nil, "log message", context, event)
      msgpack = log_entry.to_msgpack
      expect(msgpack).to start_with("\x86\xA5level\xA4INFO\xA2dt\xBB2016-09-01T12:00:00.000000Z".force_encoding("ASCII-8BIT"))
    end
  end
end