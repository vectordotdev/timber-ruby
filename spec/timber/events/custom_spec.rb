require "spec_helper"

describe Timber::Events::Custom, :rails_23 => true do
  describe ".to_hash" do
    it "should coerce type into an atom" do
      custom_event = described_class.new(:type => "my type", :message => "hello", :data => {:key => "value"})
      hash = custom_event.to_hash()
      expect(hash.keys.first).to eq(:"my type")
    end

    it "should coerce a Time into a float representing fractional milliseconds" do
      timer = Timber::Timer.start
      sleep(0.25)
      custom_event = described_class.new(:type => :my_event, :message => "hello", :data => {:time_ms => timer})
      expect(custom_event.message).to include("in ")
      expect(custom_event.message).to end_with("ms")
      data = custom_event.data
      expect(data[:time_ms]).to be_kind_of(Float)
      expect(data[:time_ms]).to be > 0.0
    end
  end

  describe "#new" do
    it "does not require data key" do
      custom_event = described_class.new(:type => "my type", :message => "hello")
    end
  end

  describe "#as_json" do
    it "should render an empty data hash" do
      custom_event = described_class.new(:type => "my type", :message => "hello")
      hash = custom_event.as_json()
      expect(hash).to eq({:custom => {:"my type" => {}}})
    end
  end
end
