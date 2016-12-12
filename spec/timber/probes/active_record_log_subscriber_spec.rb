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
            message = "  \e[1m\e[36mUser Load (0.0ms)\e[0m  \e[1m\e[34mSELECT \"users\".* FROM \"users\" ORDER BY users.id DESC\e[0m @timber.io {\"level\":\"debug\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"sql_query\":{\"sql\":\"SELECT \\\"users\\\".* FROM \\\"users\\\" ORDER BY users.id DESC\",\"time_ms\":0.0}}}\n"
            # Rails 4.X adds random spaces :/
            string = io.string.gsub("   ORDER BY", " ORDER BY")
            string = string.gsub("  ORDER BY", " ORDER BY")
            expect(string).to include("users.id DESC")
            expect(string).to include("@timber.io")
            expect(string).to include("\"level\":\"debug\"")
            expect(string).to include("\"sql\":")
          end
        end
      end
    end
  end
end