require "spec_helper"

describe Timber::Macros::Compactor do
  describe ".compact" do
    let(:hash) { {} }
    subject { described_class.compact(hash) }
    it { should eq({}) }

    context "nested" do
      let(:hash) { {:whatever => {:nested => nil}} }
      it { should eq({}) }
    end

    context "nested with other values" do
      let(:hash) { {:whatever => {:nested => nil, :with_val => 1}, :another => 1} }
      it { should eq({:whatever => {:with_val => 1}, :another => 1}) }
    end
  end
end