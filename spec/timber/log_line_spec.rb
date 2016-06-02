require "spec_helper"

describe Timber::LogLine do
  let(:message) { "this is a message" }
  let(:log_line) { described_class.new(message) }

  describe "#initialize" do
    subject { log_line }

    its(:dt) { should_not be_nil }
    its(:message) { should equal(message) }
  end

  describe "#json" do
    let(:json) { "{\"dt\":#{log_line.dt.iso8601.to_json}, \"message\":#{log_line.message.to_json}, \"context\":#{log_line.context_json}}" }
    subject { log_line.json }
    it { should eq(json) }
  end
end
