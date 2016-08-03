require "spec_helper"

describe Timber::CurrentLineIndexes do
  def add_log_line
    Timber::LogLine.new("test")
  end

  describe "#log_line_added" do
    fit "only includes the valid stack" do
      expect(Timber::CurrentContext).to receive(:valid_stack).twice.and_return([])
      add_log_line
    end

    context "with a context" do
      let(:heroku_context) { Timber::Contexts::Heroku.new("web.1")}

      around(:each) do |example|
        Timber::CurrentContext.add(heroku_context) do
          example.run
        end
      end

      it "sets the context to 0" do
        add_log_line
        expect(described_class.indexes).to eq({heroku_context => 0})
      end

      context "with an additional log line" do
        before(:each) { add_log_line }

        it "increments properly" do
          add_log_line
          expect(described_class.indexes).to eq({heroku_context => 1})
        end
      end
    end
  end
end
