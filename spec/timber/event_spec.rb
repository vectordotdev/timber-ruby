require "spec_helper"

describe Timber::Event, :rails_23 => true do
  describe "#to_s" do
    it "should display the message" do
      event = Timber::Events::Custom.new(message: "Build version 1.0.0", type: :build, data: {version: "1.0.0"})
      expect(event.to_s).to eq("Build version 1.0.0")
    end
  end
end