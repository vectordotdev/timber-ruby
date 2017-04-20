require "spec_helper"

describe Timber::Util::HTTPEvent, :rails_23 => true do
  describe ".normalize_headers" do
    it "should ignore nils" do
      result = described_class.normalize_headers({"key" => nil})
      expect(result).to eq({"key" => nil})
    end
  end
end