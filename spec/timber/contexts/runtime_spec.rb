require "spec_helper"

describe Timber::Contexts::Runtime, :rails_23 => true do
  describe ".as_json" do
    it "should coerce vm_pid into an string" do
      custom_context = described_class.new(:vm_pid => 1)
      json = custom_context.as_json()
      expect(json[:vm_pid]).to eq("1")
    end
  end
end