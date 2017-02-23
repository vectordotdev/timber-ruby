require "spec_helper"

describe Timber::Contexts::Custom, :rails_23 => true do
  describe ".as_json" do
    it "should coerce type into an atom" do
      custom_context = described_class.new(:type => "my type", :data => {:key => "value"})
      json = custom_context.as_json()
      expect(json.keys.first).to eq(:"my type")
    end
  end
end