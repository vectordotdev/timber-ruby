require "spec_helper"

describe Timber::Probes::RailsRackLogger do
  describe described_class::InstanceMethods do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
    let(:io) { StringIO.new }
    let(:logger) do
      logger = Timber::Logger.new(io)
      logger.level = ::Logger::INFO
      logger
    end

    around(:each) do |example|
      class RailsRackLoggerController < ActionController::Base
        layout nil

        def index
          render json: {}
        end

        def method_for_action(action_name)
          action_name
        end
      end

      ::RailsApp.routes.draw do
        get '/rails_rack_logger' => 'rails_rack_logger#index'
      end

      Timecop.freeze(time) { example.run }

      Object.send(:remove_const, :RailsRackLoggerController)
    end

    describe "#started_request_message" do
      it "should set the context" do
        allow(::Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production")) # Rails 3.2.X
        allow(::Rails).to receive(:logger).and_return(logger) # Rails 3.2.X
        allow_any_instance_of(::Rails::Rack::Logger).to receive(:logger).and_return(logger)
        dispatch_rails_request("/rails_rack_logger")
        message = "Started GET \"/rails_rack_logger\" for 123.456.789.10 @timber.io {\"level\":\"info\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"server_side_app\":{\"http_request\":{\"host\":\"example.org\",\"method\":\"GET\",\"path\":\"/rails_rack_logger\",\"port\":80,\"headers\":{\"remote_addr\":\"123.456.789.10\",\"request_id\":\"unique-request-id-1234\"}}}},\"context\":{\"http\":{\"method\":\"GET\",\"path\":\"/rails_rack_logger\",\"remote_addr\":\"123.456.789.10\",\"request_id\":\"unique-request-id-1234\"}}}\n"
        expect(io.string).to eq(message)
      end
    end
  end
end