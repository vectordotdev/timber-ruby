require "spec_helper"

describe Timber::LogLine do
  let(:message) { "this is a message" }
  let(:log_line) { described_class.new(message) }

  around(:each) do |example|
    heroku = Timber::Contexts::Heroku.new("web.1")
    Timber::CurrentContext.add(heroku) { example.run }
  end

  describe "#initialize" do
    subject { log_line }

    its(:dt) { should_not be_nil }
    its(:message) { should equal(message) }

    context "non string" do
      let(:message) { :"this is a message" }
      its(:message) { should eq(message.to_s) }
    end

    context "exceeds bytesize limit" do
      let(:limit) { Timber::APISettings::MESSAGE_BYTE_SIZE_MAX }
      let(:message) { (1..(limit + 1)).collect { "A" }.join }
      subject { lambda { log_line } }
      it { should raise_error(Timber::LogLine::InvalidMessageError, "the log message must not exceed #{limit} bytes") }
    end
  end

  describe "#json" do
    # Note: very important that we keep the iso8601 format. Otherwise the Timber API
    # will recognized the date as invalid.
    let(:json) { "{\"dt\":#{log_line.dt.iso8601.to_json}, \"message\":#{log_line.message.to_json}, \"context\":#{log_line.context_json}}" }
    subject { log_line.json }
    it { should eq(json) }
  end
end
