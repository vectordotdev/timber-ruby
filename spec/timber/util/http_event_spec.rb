require "spec_helper"

describe Timber::Util::HTTPEvent, :rails_23 => true do
  describe ".normalize_headers" do
    it "should ignore nils" do
      result = described_class.normalize_headers({"key" => nil})
      expect(result).to eq({"key" => nil})
    end

    it "should handle non strings" do
      result = described_class.normalize_headers({"key" => 1})
      expect(result).to eq({"key" => 1})
    end
  end
end