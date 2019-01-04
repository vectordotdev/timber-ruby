require "spec_helper"

describe Timber::Contexts::System, :rails_23 => true do
  describe ".to_hash" do
    it "should coerce pid into an integer" do
      custom_context = described_class.new(:pid => "1")
      json = custom_context.to_hash()
      expect(json[:pid]).to eq(1)
    end
  end
end
