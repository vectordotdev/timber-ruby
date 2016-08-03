require "spec_helper"

describe Timber::ContextSnapshot do
  describe "#initialize" do
    it "only includes the valid stack" do
      expect(Timber::CurrentContext).to receive(:valid_stack).once.and_return([])
      described_class.new
    end
  end
end
