require "spec_helper"

describe Timber::LogDevices::HTTP::TriggeredBuffer do
  describe "#write" do
    it "should trigger a buffer overflow for large messages" do
      buffer = described_class.new(:payload_limit_bytes => 10)
      msg = "a" * 11
      expect(buffer).to receive(:handle_overflow).exactly(1).times.with(msg)
      buffer.write(msg)
    end

    it "should trigger a buffer overflow when exceeding the limit" do
      buffer = described_class.new(:limit_bytes => 10)
      msg = "a" * 11
      expect(buffer).to receive(:handle_overflow).exactly(1).times.with(msg)
      buffer.write(msg)
    end

    it "should start a new buffer when empty and append when not" do
      buffer = described_class.new
      result = buffer.write("test")
      expect(result).to be_nil
      expect(buffer.send(:writable_buffer)).to eq("test")
      result = buffer.write("again")
      expect(result).to be_nil
      expect(buffer.send(:writable_buffer)).to eq("testagain")
    end

    it "should return the old buffer when it has exceeded it's limit" do
      buffer = described_class.new(:payload_limit_bytes => 10)
      msg = "a" * 6
      result = buffer.write(msg)
      expect(result).to be_nil
      result = buffer.write(msg)
      expect(result).to eq(msg)
      expect(result).to be_frozen
    end

    it "should write a new buffer when the latest is frozen" do
      buffer = described_class.new
      buffer.write("test")
      result = buffer.reserve
      expect(result).to eq("test")
      buffer.write("again")
      expect(buffer.send(:writable_buffer)).to eq("again")
    end
  end

  describe "#reserve" do
    it "should reserve the latest buffer and freeze it" do
      buffer = described_class.new
      buffer.write("test")
      result = buffer.reserve
      expect(result).to eq("test")
      expect(result).to be_frozen
    end
  end
end