require "spec_helper"

describe Timber::Contexts::Exception do
  let(:exception) do
    begin
      raise StandardError.new("this is a message")
    rescue Exception => e
      e
    end
  end
  let(:context) { described_class.new(exception) }

  describe ".as_json" do
    subject { context.as_json }
    its([:exception, :backtrace]) { should_not be_nil }
    its([:exception, :name]) { should eq("StandardError") }
    its([:exception, :message]) { should eq("this is a message") }
  end

  describe ".backtrace" do
    subject { context.backtrace }
    its(:size) { should eq(5) }
  end

  describe ".name" do
    subject { context.name }
    it { should eq("StandardError") }
  end

  describe ".message" do
    subject { context.message }
    it { should eq("this is a message") }
  end
end
