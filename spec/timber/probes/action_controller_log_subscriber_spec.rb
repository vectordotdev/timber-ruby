require "spec_helper"

describe Timber::Probes::ActionControllerLogSubscriber do
  describe described_class::LogSubscriber do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
    let(:io) { StringIO.new }
    let(:logger) do
      logger = Timber::Logger.new(io)
      logger.level = ::Logger::WARN
      logger
    end

    around(:each) do |example|
      Timecop.freeze(time) { example.run }
    end

    before(:each) do
      class PagesPlainController < ActionController::Base
        layout nil

        def index
          render json: {}
        end

        def method_for_action(action_name)
          action_name
        end
      end

      ::RailsApp.routes.draw do
        get 'pages_plain' => 'pages_plain#index'
      end

      @old_logger = ::ActionController::Base.logger
      ::ActionController::Base.logger = logger
    end

    after(:each) do
      Object.send(:remove_const, :PagesPlainController)
      ::ActionController::Base.logger = @old_logger
    end

    describe "#process" do
      it "should not log if the level is not sufficient" do
        dispatch_rails_request("/pages_plain")
        expect(io.string).to eq("")
      end

      context "with an info level" do
        around(:each) do |example|
          old_level = logger.level
          logger.level = ::Logger::INFO
          example.run
          logger.level = old_level
        end

        it "should log the controller call event" do
          dispatch_rails_request("/pages_plain")
          message = <<-MSG
            Processing by PagesPlainController#index as HTML @timber.io {"level":"info","dt":"2016-09-01T12:00:00.000000Z","event":{"controller_call":{"controller":"PagesPlainController","action":"index"}},"context":{"http":{"method":"GET","path":"/pages_plain","remote_addr":"123.456.789.10","request_id":"unique-request-id-1234"}}}
          MSG
          expect(io.string).to eq(message.strip)
        end
      end
    end
  end
end