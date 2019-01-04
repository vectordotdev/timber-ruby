require "spec_helper"

describe Timber::Contexts::Custom, :rails_23 => true do
  describe ".to_hash" do
    it "should coerce type into an atom" do
      custom_context = described_class.new(:type => "my type", :data => {:key => "value"})
      json = custom_context.to_hash()
      expect(json.keys.first).to eq(:"my type")
    end
  end
end
