require "spec_helper"

describe Timber::LogLine do
  let(:message) { "this is a message" }
  let(:log_line) { described_class.new(message) }

  describe "#initialize" do
    subject { log_line }

    its(:dt) { should_not be_nil }
    its(:message) { should equal(message) }
  end

  describe "#to_hash" do
    subject { log_line.to_hash }
    its([:dt]) { should eq(log_line.dt.strftime("%FT%T.%6N%:z")) }
    its([:message]) { should eq(message) }
    its([:context]) { should eq({}) }
  end

  describe "#to_json" do
    let(:hash) { log_line.to_hash }
    subject { log_line.to_json }
    it { should eq(hash.to_json) }
  end
end
