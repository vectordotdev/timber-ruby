require "spec_helper"

describe Timber::Patterns::ToJSON do
  class TestJSON
    include Timber::Patterns::ToJSON

    attr_reader :json_payload

    def initialize(json_payload)
      @json_payload = json_payload
    end
  end

  describe ".as_json" do
    let(:hash) { {} }
    let(:target) { TestJSON.new(hash) }
    subject { target.as_json }
    it { should eq({}) }

    context "with a value" do
      let(:hash) { {:test => 1} }
      it { should eq({"test" => 1}) }
    end

    context "with a nil value" do
      let(:hash) { {:test => nil} }
      it { should eq({}) }
    end

    context "with an empty array" do
      let(:hash) { {:test => []} }
      it { should eq({}) }
    end
  end
end
