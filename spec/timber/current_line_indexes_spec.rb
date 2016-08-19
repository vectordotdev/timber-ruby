require "spec_helper"

describe Timber::CurrentLineIndexes do
  def add_log_line
    Timber::LogLine.new("test")
  end

  describe "#log_line_added" do
    it "only includes the valid stack" do
      expect(Timber::CurrentContext).to receive(:valid_stack).twice.and_return([])
      add_log_line
    end

    context "with a context" do
      let(:heroku_context) { Timber::Contexts::Servers::HerokuSpecific.new("web.1")}

      around(:each) do |example|
        Timber::CurrentContext.add(heroku_context) do
          example.run
        end
      end

      context "with a log line" do
        before(:each) { add_log_line }

        it "sets the context to 0" do
          expect(described_class.indexes[heroku_context]).to eq(0)
        end

        context "with an additional log line" do
          before(:each) { add_log_line }

          it "increments properly" do
            expect(described_class.indexes[heroku_context]).to eq(1)
          end
        end
      end
    end
  end
end
