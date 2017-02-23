require "spec_helper"

describe Timber::Contexts::Organization, :rails_23 => true do
  describe ".as_json" do
    it "should coerce id into a string" do
      user_context = described_class.new(:id => 1)
      json = user_context.as_json()
      expect(json[:id]).to eq("1")
    end
  end
end