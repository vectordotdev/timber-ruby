require "spec_helper"

describe Timber::CurrentContext, :rails_23 => true do
  describe ".add" do
    after(:each) do
      described_class.reset
    end

    it "should add the context" do
      expect(described_class.hash).to eq({})

      described_class.add({build: {version: "1.0.0"}})
      expect(described_class.hash).to eq({:custom=>{:build=>{:version=>"1.0.0"}}})

      described_class.add({testing: {key: "value"}})
      expect(described_class.hash).to eq({:custom=>{:build=>{:version=>"1.0.0"}, :testing=>{:key=>"value"}}})
    end
  end

  describe ".remove" do
    it "should remove the context by object" do
      context = {:build=>{:version=>"1.0.0"}}
      described_class.add(context)
      expect(described_class.hash).to eq({:custom => context})

      described_class.remove(context)
      expect(described_class.hash).to eq({})
    end

    it "should remove context by key" do
      context = {:build=>{:version=>"1.0.0"}}
      described_class.add(context)
      expect(described_class.hash).to eq({:custom => context})

      described_class.remove(:custom)
      expect(described_class.hash).to eq({})
    end
  end

  describe ".with" do
    it "should merge the context and cleanup on block exit" do
      expect(described_class.hash).to eq({})

      described_class.with({build: {version: "1.0.0"}}) do
        expect(described_class.hash).to eq({:custom=>{:build=>{:version=>"1.0.0"}}})

        described_class.with({testing: {key: "value"}}) do
          expect(described_class.hash).to eq({:custom=>{:build=>{:version=>"1.0.0"}, :testing=>{:key=>"value"}}})
        end

        expect(described_class.hash).to eq({:custom=>{:build=>{:version=>"1.0.0"}}})
      end

      expect(described_class.hash).to eq({})
    end
  end
end