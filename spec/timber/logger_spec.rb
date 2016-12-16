require "spec_helper"

describe Timber::Logger, :rails_23 => true do
  describe "#add" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
    let(:io) { StringIO.new }
    let(:logger) { Timber::Logger.new(io) }

    around(:each) do |example|
      Timecop.freeze(time) { example.run }
    end

    context "with the :hybrid format" do
      before(:each) { logger.formatter = Timber::Logger::HybridFormatter.new }

      it "should accept strings" do
        logger.info("this is a test")
        expect(io.string).to eq("this is a test @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\"}\n")
      end

      context "with a context" do
        let(:http_context) do
          Timber::Contexts::HTTP.new(
            method: "POST",
            path: "/checkout",
            remote_addr: "123.456.789.10",
            request_id: "abcd1234"
          )
        end

        around(:each) do |example|
          Timber::CurrentContext.with(http_context) do
            example.run
          end
        end

        it "should snapshot and include the context" do
          expect(Timber::CurrentContext.instance).to receive(:snapshot).and_call_original
          logger.info("this is a test")
          expect(io.string).to eq("this is a test @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"context\":{\"http\":{\"method\":\"POST\",\"path\":\"/checkout\",\"remote_addr\":\"123.456.789.10\",\"request_id\":\"abcd1234\"}}}\n")
        end
      end

      it "should call and use Timber::Events.build" do
        message = {message: "payment rejected", type: :payment_rejected, data: {customer_id: "abcde1234", amount: 100}}
        expect(Timber::Events).to receive(:build).with(message).and_call_original
        logger.info(message)
        expect(io.string).to eq("payment rejected @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"custom\":{\"payment_rejected\":{\"customer_id\":\"abcde1234\",\"amount\":100}}}}\n")
      end

      it "should log properly when an event is passed" do
        message = Timber::Events::SQLQuery.new(sql: "select * from users", time_ms: 56, message: "select * from users")
        logger.info(message)
        expect(io.string).to eq("select * from users @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"sql_query\":{\"sql\":\"select * from users\",\"time_ms\":56}}}\n")
      end

      it "should allow functions" do
        logger.info do
          {message: "payment rejected", type: :payment_rejected, data: {customer_id: "abcde1234", amount: 100}}
        end
        expect(io.string).to eq("payment rejected @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"custom\":{\"payment_rejected\":{\"customer_id\":\"abcde1234\",\"amount\":100}}}}\n")
      end

      it "should escape new lines" do
        logger.info "first\nsecond"
        expect(io.string).to eq("first\\nsecond @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\"}\n")
      end
    end

    context "with the :json format" do
      before(:each) { logger.formatter = Timber::Logger::JSONFormatter.new }

      it "should log in the correct format" do
        logger.info("this is a test")
        expect(io.string).to eq("{\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"message\":\"this is a test\"}\n")
      end
    end

    if defined?(ActiveSupport::TaggedLogging)
      context "with TaggedLogging", :rails_23 => false do
        let(:logger) { ActiveSupport::TaggedLogging.new(Timber::Logger.new(io)) }

        it "should format properly with events" do
          message = Timber::Events::SQLQuery.new(sql: "select * from users", time_ms: 56, message: "select * from users")
          logger.tagged("tag") do
            logger.info(message)
          end
          expect(io.string).to eq("select * from users @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"sql_query\":{\"sql\":\"select * from users\",\"time_ms\":56}},\"context\":{\"tags\":[\"tag\"]}}\n")
        end
      end
    end

    context "with the HTTP log device" do
      let(:io) { Timber::LogDevices::HTTP.new("my_key") }

      it "should use the msgpack formatter" do
        expect(logger.formatter).to be_kind_of(Timber::Logger::MsgPackFormatter)
      end

      it "should log properly with the msgpack format" do
        event = Timber::Events::Custom.new(
          type: :payment_rejected,
          message: "Payment rejected",
          data: {customer_id: "abcd1234", amount: 100}
        )
        expect(io).to receive(:write).exactly(1).times
        logger.error(event)
      end
    end
  end
end