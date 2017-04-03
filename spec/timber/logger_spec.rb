require "spec_helper"

describe Timber::Logger, :rails_23 => true do
  describe "#add" do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
    let(:io) { StringIO.new }
    let(:logger) { Timber::Logger.new(io) }

    around(:each) do |example|
      Timecop.freeze(time) { example.run }
    end

    context "with the StringFormatter" do
      before(:each) { logger.formatter = Timber::Logger::StringFormatter.new }

      it "should accept strings" do
        logger.info("this is a test")
        expect(io.string).to start_with("this is a test @metadata {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\"")
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
          expect(io.string).to start_with("this is a test @metadata {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\"")
          expect(io.string).to include("\"http\":{\"method\":\"POST\",\"path\":\"/checkout\",\"remote_addr\":\"123.456.789.10\",\"request_id\":\"abcd1234\"}")
        end
      end

      it "should call and use Timber::Events.build" do
        message = {message: "payment rejected", payment_rejected: {customer_id: "abcde1234", amount: 100}}
        expect(Timber::Events).to receive(:build).with(message).and_call_original
        logger.info(message)
        expect(io.string).to start_with("payment rejected @metadata {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",")
        expect(io.string).to include("\"event\":{\"custom\":{\"payment_rejected\":{\"customer_id\":\"abcde1234\",\"amount\":100}}}")
      end

      it "should log properly when an event is passed" do
        message = Timber::Events::SQLQuery.new(sql: "select * from users", time_ms: 56, message: "select * from users")
        logger.info(message)
        expect(io.string).to start_with("select * from users @metadata {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",")
        expect(io.string).to include("\"event\":{\"server_side_app\":{\"sql_query\":{\"sql\":\"select * from users\",\"time_ms\":56.0}}}")
      end

      it "should allow :time_ms" do
        logger.info("event complete", time_ms: 54.5)
        expect(io.string).to include("\"time_ms\":54.5")
      end

      it "should allow :tag" do
        logger.info("event complete", tag: "tag1")
        expect(io.string).to include("\"tags\":[\"tag1\"]")
      end

      it "should allow :tags" do
        logger.info("event complete", tags: ["tag1", "tag2"])
        expect(io.string).to include("\"tags\":[\"tag1\",\"tag2\"]")
      end

      it "should allow functions" do
        logger.info do
          {message: "payment rejected", payment_rejected: {customer_id: "abcde1234", amount: 100}}
        end
        expect(io.string).to start_with("payment rejected @metadata {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",")
        expect(io.string).to include("\"event\":{\"custom\":{\"payment_rejected\":{\"customer_id\":\"abcde1234\",\"amount\":100}}}")
      end

      it "should escape new lines" do
        logger.info "first\nsecond"
        expect(io.string).to start_with("first\\nsecond @metadata")
      end
    end

    context "with the :json format" do
      before(:each) { logger.formatter = Timber::Logger::JSONFormatter.new }

      it "should log in the correct format" do
        logger.info("this is a test")
        expect(io.string).to start_with("{\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"message\":\"this is a test\"")
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
          expect(io.string).to include("\"tags\":[\"tag\"]")
        end
      end
    end

    context "with the HTTP log device" do
      let(:io) { Timber::LogDevices::HTTP.new("my_key") }

      it "should use the PassThroughFormatter" do
        expect(logger.formatter).to be_kind_of(Timber::Logger::PassThroughFormatter)
      end
    end
  end

  describe "#formatter=" do
    it "should not allow changing the formatter when the device is HTTP" do
      http_device = Timber::LogDevices::HTTP.new("api_key")
      logger = Timber::Logger.new(http_device)
      expect { logger.formatter = ::Logger::Formatter.new }.to raise_error(ArgumentError)
    end

    it "should set the formatter" do
      logger = Timber::Logger.new(STDOUT)
      formatter = ::Logger::Formatter.new
      logger.formatter = formatter
      expect(logger.formatter).to eq(formatter)
    end
  end

  describe "#with_context" do
    let(:io) { StringIO.new }
    let(:logger) { Timber::Logger.new(io) }

    it "should add context" do
      expect(Timber::CurrentContext.hash).to eq({})

      logger.with_context(build: {version: "1.0.0"}) do
        expect(Timber::CurrentContext.hash).to eq({:custom=>{:build=>{:version=>"1.0.0"}}})

        logger.with_context({testing: {key: "value"}}) do
          expect(Timber::CurrentContext.hash).to eq({:custom=>{:build=>{:version=>"1.0.0"}, :testing=>{:key=>"value"}}})
        end

        expect(Timber::CurrentContext.hash).to eq({:custom=>{:build=>{:version=>"1.0.0"}}})
      end

      expect(Timber::CurrentContext.hash).to eq({})
    end
  end

  describe "#info" do
    let(:io) { StringIO.new }
    let(:logger) { Timber::Logger.new(io) }

    it "should allow default usage" do
      logger.info("message")
      expect(io.string).to start_with("message @metadata")
      expect(io.string).to include('"level":"info"')
    end

    it "should allow messages with options" do
      logger.info("message", tag: "tag")
      expect(io.string).to start_with("message @metadata")
      expect(io.string).to include('"level":"info"')
      expect(io.string).to include('"tags":["tag"]')
    end
  end

  describe "#error" do
    let(:io) { StringIO.new }
    let(:logger) { Timber::Logger.new(io) }

    it "should allow default usage" do
      logger.error("message")
      expect(io.string).to start_with("message @metadata")
      expect(io.string).to include('"level":"error"')
    end

    it "should allow messages with options" do
      logger.error("message", tag: "tag")
      expect(io.string).to start_with("message @metadata")
      expect(io.string).to include('"level":"error"')
      expect(io.string).to include('"tags":["tag"]')
    end
  end
end