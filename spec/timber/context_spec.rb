require "spec_helper"

describe Timber::Context do
  let(:context) { described_class.new }

  describe "#initialize" do
    subject { context }
    its(:id) { should_not be_nil }
  end
end
