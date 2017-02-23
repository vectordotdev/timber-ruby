require "spec_helper"

describe Timber::Events::Custom, :rails_23 => true do
  describe ".to_hash" do
    it "should coerce type into an atom" do
      custom_context = described_class.new(:type => "my type", :message => "hello", :data => {:key => "value"})
      hash = custom_context.to_hash()
      expect(hash.keys.first).to eq(:"my type")
    end
  end
end