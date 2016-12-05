require "spec_helper"

describe Timber::Logger do
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
        expect(io.string).to eq("this is a test @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\"}")
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
          Timber::CurrentContext.instance.with(http_context) do
            example.run
          end
        end

        it "should snapshot and include the context" do
          expect(Timber::CurrentContext.instance).to receive(:snapshot).and_call_original
          logger.info("this is a test")
          expect(io.string).to eq("this is a test @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"context\":{\"http\":{\"method\":\"POST\",\"path\":\"/checkout\",\"remote_addr\":\"123.456.789.10\",\"request_id\":\"abcd1234\"}}}")
        end
      end

      it "should call and use Timber::Events.build" do
        message = {message: "payment rejected", type: :payment_rejected, data: {customer_id: "abcde1234", amount: 100}}
        expect(Timber::Events).to receive(:build).with(message).and_call_original
        logger.info(message)
        expect(io.string).to eq("payment rejected @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"custom\":{\"payment_rejected\":{\"customer_id\":\"abcde1234\",\"amount\":100}}}}")
      end

      it "should allow functions" do
        logger.info do
          {message: "payment rejected", type: :payment_rejected, data: {customer_id: "abcde1234", amount: 100}}
        end
        expect(io.string).to eq("payment rejected @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"custom\":{\"payment_rejected\":{\"customer_id\":\"abcde1234\",\"amount\":100}}}}")
      end
    end

    context "with the :json format" do
      before(:each) { logger.formatter = Timber::Logger::JSONFormatter.new }

      it "should log in the correct format" do
        logger.info("this is a test")
        expect(io.string).to eq("{\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"message\":\"this is a test\"}")
      end
    end
  end
end