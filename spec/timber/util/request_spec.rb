require "spec_helper"

describe Timber::Util::Request, :rails_23 => true do
  describe ".headers" do
    it "should ignore symbol keys" do
      req = described_class.new({test: "value"})
      expect(req.headers).to eq({})
    end
  end
end