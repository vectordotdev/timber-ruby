require "spec_helper"

describe Timber::LogEntry, :rails_23 => true do
  let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }

  describe "#as_json" do
    it "should drop nil value keys" do
      event = Timber::Events::Custom.new(type: :event_type, message: "event_message", data: {a: nil})
      log_entry = described_class.new("INFO", time, nil, "log message", {}, event)
      hash = log_entry.as_json
      expect(hash.key?(:event)).to be false
    end

    it "should drop blank string value keys" do
      event = Timber::Events::Custom.new(type: :event_type, message: "event_message", data: {a: ""})
      log_entry = described_class.new("INFO", time, nil, "log message", {}, event)
      hash = log_entry.as_json
      expect(hash.key?(:event)).to be false
    end

    it "should drop empty array value keys" do
      event = Timber::Events::Custom.new(type: :event_type, message: "event_message", data: {a: []})
      log_entry = described_class.new("INFO", time, nil, "log message", {}, event)
      hash = log_entry.as_json
      expect(hash.key?(:event)).to be false
    end

    it "should drop ascii-8bit (binary) value keys" do
      binary = ("a" * 1001).force_encoding("ASCII-8BIT")
      event = Timber::Events::Custom.new(type: :event_type, message: "event_message", data: {a: binary})
      log_entry = described_class.new("INFO", time, nil, "log message", {}, event)
      hash = log_entry.as_json
      expect(hash.key?(:event)).to be false
    end

    it "should keep ascii-8bit (binary) values below the threshold" do
      binary = "test".force_encoding("ASCII-8BIT")
      event = Timber::Events::Custom.new(type: :event_type, message: "event_message", data: {a: binary})
      log_entry = described_class.new("INFO", time, nil, "log message", {}, event)
      hash = log_entry.as_json
      expect(hash[:event][:custom][:event_type][:a].encoding).to eq(::Encoding::UTF_8)
    end
  end

  describe "#to_msgpack" do
    it "should encode properly with an event and context" do
      event = Timber::Events::Custom.new(type: :event_type, message: "event_message", data: {a: 1})
      custom_context = Timber::Contexts::Custom.new(type: :context_type, data: {b: 1})
      context = {custom: custom_context.as_json}
      log_entry = described_class.new("INFO", time, nil, "log message", context, event)
      msgpack = log_entry.to_msgpack
      expect(msgpack).to start_with("\x86\xA5level\xA4INFO\xA2dt\xBB2016-09-01T12:00:00.000000Z".force_encoding("ASCII-8BIT"))
    end
  end
end