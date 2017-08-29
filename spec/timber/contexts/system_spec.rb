require "spec_helper"

describe Timber::Contexts::System, :rails_23 => true do
  describe ".as_json" do
    it "should coerce pid into an integer" do
      custom_context = described_class.new(:pid => "1")
      json = custom_context.as_json()
      expect(json[:pid]).to eq(1)
    end
  end
end