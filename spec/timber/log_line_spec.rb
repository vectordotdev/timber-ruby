require "spec_helper"

describe Timber::LogLine do
  let(:message) { "this is a message" }
  let(:log_line) { described_class.new(message) }

  around(:each) do |example|
    heroku = Timber::Contexts::Servers::HerokuSpecific.new("web.1")
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

    it "notifies CurrentLineIndexes" do
      expect(Timber::CurrentLineIndexes).to receive(:log_line_added).once
      subject
    end
  end

  describe "#to_json" do
    # Note: very important that we keep the iso8601 format. Otherwise the Timber API
    # will recognized the date as invalid.
    let(:as_json) do
      {
        dt: log_line.dt.iso8601(6),
        message: log_line.message,
      }.merge(log_line.context_snapshot.as_json)
    end
    let(:json) { as_json.to_json }
    subject { log_line.to_json }
    it { should eq(json) }
  end

  describe "#to_logfmt" do
    let(:logfmt) do
      "dt=#{log_line.dt.iso8601(6)} message=#{log_line.message.to_json}" +
        "\n\t#{log_line.context_snapshot.to_logfmt(:delimiter => "\n\t")}"
    end
    subject { log_line.to_logfmt }
    it { should eq(logfmt) }
  end
end
