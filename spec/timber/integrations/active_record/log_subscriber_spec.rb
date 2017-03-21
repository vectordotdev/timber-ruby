require "spec_helper"

describe Timber::Integrations::ActiveRecord::LogSubscriber do
  let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
  let(:io) { StringIO.new }
  let(:logger) do
    logger = Timber::Logger.new(io)
    logger.level = ::Logger::INFO
    logger
  end

  describe "#insert!" do
    around(:each) do |example|
      with_rails_logger(logger) do
        Timecop.freeze(time) { example.run }
      end
    end

    it "should not log if the level is not sufficient" do
      User.order("users.id DESC").all.collect # collect kicks the sql because it is lazily executed
      expect(io.string).to eq("")
    end

    context "with an info level" do
      around(:each) do |example|
        old_level = logger.level
        logger.level = ::Logger::DEBUG
        example.run
        logger.level = old_level
      end

      it "should log the sql query" do
        User.order("users.id DESC").all.collect # collect kicks the sql because it is lazily executed
        # Rails 4.X adds random spaces :/
        string = io.string.gsub("   ORDER BY", " ORDER BY")
        string = string.gsub("  ORDER BY", " ORDER BY")
        expect(string).to include("users.id DESC")
        expect(string).to include("@metadata")
        expect(string).to include("\"level\":\"debug\"")
        expect(string).to include("\"event\":{\"server_side_app\":{\"sql_query\"")
      end
    end
  end
end