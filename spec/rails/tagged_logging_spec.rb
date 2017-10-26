require "spec_helper"

# ActiveSupport::TaggedLogging is not defined in <= 3.1
if defined?(::ActiveSupport::TaggedLogging)
  describe ActiveSupport::TaggedLogging, :rails_23 => true do
    describe "#new" do
      let(:io) { StringIO.new }

      it "should instantiate for Timber::Logger object" do
        ActiveSupport::TaggedLogging.new(Timber::Logger.new(io))
      end

      if defined?(ActiveSupport::BufferedLogger)
        it "should instantiate for a ActiveSupport::BufferedLogger object" do
          ActiveSupport::TaggedLogging.new(ActiveSupport::BufferedLogger.new(io))
        end
      end
    end

    describe "#info" do
      let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
      let(:io) { StringIO.new }
      let(:logger) { ActiveSupport::TaggedLogging.new(Timber::Logger.new(io)) }

      around(:each) do |example|
        Timecop.freeze(time) { example.run }
      end

      it "should format properly with events" do
        event = Timber::Events::SQLQuery.new(sql: "select * from users", time_ms: 56, message: "select * from users")
        logger.tagged("tag") do
          logger.info(event)
        end
        expect(io.string).to include("\"tags\":[\"tag\"]")
      end

      it "should accept events as the second argument" do
        logger.info("SQL query", payment_rejected: {customer_id: "abcd1234", amount: 100, reason: "Card expired"})
        expect(io.string).to start_with("SQL query @metadata")
        expect(io.string).to include("\"event\":{\"custom\":{\"payment_rejected\":")
      end
    end
  end
end