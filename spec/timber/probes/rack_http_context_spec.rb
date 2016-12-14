require "spec_helper"

describe Timber::Probes::RackHTTPContext do
  describe described_class::Middleware do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
    let(:io) { StringIO.new }
    let(:logger) do
      logger = Timber::Logger.new(io)
      logger.level = ::Logger::INFO
      logger
    end

    around(:each) do |example|
      class RackHttpController < ActionController::Base
        layout nil

        def index
          Thread.current[:_timber_context] = Timber::CurrentContext.instance.snapshot
          render json: {}
        end

        def method_for_action(action_name)
          action_name
        end
      end

      ::RailsApp.routes.draw do
        get '/rack_http' => 'rack_http#index'
      end

      Timecop.freeze(time) { example.run }

      Object.send(:remove_const, :RackHttpController)
    end

    describe "#process" do
      it "should set the context" do
        allow(Benchmark).to receive(:ms).and_return(1).and_yield
        allow_any_instance_of(Timber::Probes::ActionControllerLogSubscriber::LogSubscriber).to receive(:logger).and_return(logger)

        dispatch_rails_request("/rack_http")
        http_context = Thread.current[:_timber_context][:http]

        expect(http_context).to eq({:method=>"GET", :path=>"/rack_http", :remote_addr=>"123.456.789.10", :request_id=>"unique-request-id-1234"})
        message = "Processing by RackHttpController#index as HTML @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"controller_call\":{\"controller\":\"RackHttpController\",\"action\":\"index\"}},\"context\":{\"http\":{\"method\":\"GET\",\"path\":\"/rack_http\",\"remote_addr\":\"123.456.789.10\",\"request_id\":\"unique-request-id-1234\"}}}\nCompleted 200 OK in 0.0ms (Views: 1.0ms) @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"http_response\":{\"status\":200,\"time_ms\":0.0}},\"context\":{\"http\":{\"method\":\"GET\",\"path\":\"/rack_http\",\"remote_addr\":\"123.456.789.10\",\"request_id\":\"unique-request-id-1234\"}}}\n"
        expect(io.string).to eq(message)
      end
    end
  end
end