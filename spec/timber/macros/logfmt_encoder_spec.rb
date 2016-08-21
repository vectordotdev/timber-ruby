require "spec_helper"

describe Timber::Macros::LogfmtEncoder do
  describe ".encode" do
    subject { described_class.encode(target) }

    context "nil" do
      let(:target) { nil }
      it "should raise" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end

    context "blank hash" do
      let(:target) { {} }
      it { should eq("") }
    end

    context "simple hash" do
      let(:target) { {"key" => "value"} }
      it { should eq("key=value") }
    end

    context "with space in value" do
      let(:target) { {"key" => "this is a value"} }
      it { should eq("key=\"this is a value\"") }
    end

    context "with quote in value" do
      let(:target) { {"key" => "value\"another"} }
      it { should eq("key=\"value\\\"another\"") }
    end

    context "with a space in the key" do
      let(:target) { {"this is a key" => "value"} }
      it { should eq("\"this is a key\"=value") }
    end

    context "with a . in the key" do
      let(:target) { {"this.is.a.key" => "value"} }
      it { should eq("\"this.is.a.key\"=value") }
    end

    context "with a nested hash" do
      let(:target) { {"key" => {"sub_key" => "value"}} }
      it { should eq("key.sub_key=value") }
    end

    context "with a nested hash and space in the key" do
      let(:target) { {"key" => {"sub key" => "value"}} }
      it { should eq("key.\"sub key\"=value") }
    end

    context "with a nested hash and . in the key" do
      let(:target) { {"key" => {"sub.key" => "value"}} }
      it { should eq("key.\"sub.key\"=value") }
    end

    context "with an integer value" do
      let(:target) { {"key" => 1} }
      it { should eq("key=1") }
    end

    context "with a float value" do
      let(:target) { {"key" => 1.23} }
      it { should eq("key=1.23") }
    end

    context "with a true value" do
      let(:target) { {"key" => true} }
      it { should eq("key=true") }
    end

    context "with a false value" do
      let(:target) { {"key" => false} }
      it { should eq("key=false") }
    end

    context "with an array value" do
      let(:target) { {"key" => ["this is a value",2,3]} }
      it { should eq("key=[\"this is a value\",2,3]") }
    end
  end
end