require "spec_helper"

describe Timber::Probes::ActionControllerLogSubscriber do
  if defined?(described_class::LogSubscriber)
    describe described_class::LogSubscriber do
      let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
      let(:io) { StringIO.new }
      let(:logger) do
        logger = Timber::Logger.new(io)
        logger.level = ::Logger::WARN
        logger
      end

      around(:each) do |example|
        class LogSubscriberController < ActionController::Base
          layout nil

          def index
            render json: {}
          end

          def method_for_action(action_name)
            action_name
          end
        end

        ::RailsApp.routes.draw do
          get 'log_subscriber' => 'log_subscriber#index'
        end

        old_logger = ::ActionController::Base.logger
        ::ActionController::Base.logger = logger

        Timecop.freeze(time) { example.run }

        Object.send(:remove_const, :LogSubscriberController)
        ::ActionController::Base.logger = old_logger
      end

      describe "#start_processing, #process_action" do
        it "should not log if the level is not sufficient" do
          dispatch_rails_request("/log_subscriber")
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
            # Rails uses this to calculate the view runtime below
            allow(Benchmark).to receive(:ms).and_return(1).and_yield
            dispatch_rails_request("/log_subscriber")
            lines = io.string.split("\n")
            expect(lines.length).to eq(2)
            expect(lines[0]).to start_with('Processing by LogSubscriberController#index as HTML @metadata {"level":"info","dt":"2016-09-01T12:00:00.000000Z"')
            expect(lines[0]).to include('"event":{"server_side_app":{"controller_call":{"controller":"LogSubscriberController","action":"index"}}}')
            expect(lines[1]).to start_with('Completed 200 OK in 0.0ms (Views: 1.0ms) @metadata {"level":"info","dt":"2016-09-01T12:00:00.000000Z"')
            expect(lines[1]).to include('"event":{"server_side_app":{"http_server_response":{"status":200,"time_ms":0.0}}}')
          end
        end
      end
    end
  end
end