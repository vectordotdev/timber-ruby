require "spec_helper"

describe Timber::Probes::ActiveRecordLogSubscriber do
  if defined?(described_class::LogSubscriber)
    describe described_class::LogSubscriber do
      let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
      let(:io) { StringIO.new }
      let(:logger) do
        logger = Timber::Logger.new(io)
        logger.level = ::Logger::INFO
        logger
      end

      around(:each) do |example|
        old_logger = ::ActiveRecord::Base.logger
        ::ActiveRecord::Base.logger = logger

        Timecop.freeze(time) { example.run }

        ::ActiveRecord::Base.logger = old_logger
      end

      describe "#sql" do
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
  end
end