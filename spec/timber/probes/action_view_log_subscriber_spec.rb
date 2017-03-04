require "spec_helper"

describe Timber::Probes::ActionViewLogSubscriber do
  let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
  let(:io) { StringIO.new }
  let(:logger) do
    logger = Timber::Logger.new(io)
    logger.level = ::Logger::WARN
    logger
  end

  describe "insert!" do
    around(:each) do |example|
      class ActionViewLogSubscriberController < ActionController::Base
        layout nil

        def index
          render template: "template"
        end

        def method_for_action(action_name)
          action_name
        end
      end

      ::RailsApp.routes.draw do
        get 'action_view_log_subscriber' => 'action_view_log_subscriber#index'
      end

      Timecop.freeze(time) { example.run }

      Object.send(:remove_const, :ActionViewLogSubscriberController)
    end

    describe "#render_template" do
      it "should not log if the level is not sufficient" do
        allow_any_instance_of(Timber::Probes::ActionViewLogSubscriber::LogSubscriber).to receive(:logger).and_return(logger)
        dispatch_rails_request("/action_view_log_subscriber")
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
          allow_any_instance_of(Timber::Probes::ActionViewLogSubscriber::LogSubscriber).to receive(:logger).and_return(logger)
          dispatch_rails_request("/action_view_log_subscriber")
          expect(io.string).to start_with("  Rendered spec/support/rails/templates/template.html (0.0ms) @metadata {\"level\":\"info\"")
          expect(io.string).to include("\"event\":{\"server_side_app\":{\"template_render\":{\"name\":\"spec/support/rails/templates/template.html\",\"time_ms\":0.0}}},")
        end
      end
    end
  end

  if defined?(described_class::LogSubscriber)
    describe described_class::LogSubscriber do
      let(:event) do
        event = Struct.new(:duration, :payload)
        event.new(2, identifier: "path/to/template.html")
      end

      around(:each) do |example|
        old_level = logger.level
        logger.level = ::Logger::INFO
        example.run
        logger.level = old_level
      end

      describe "#render_template" do
        it "should render the collection" do
          log_subscriber = described_class.new
          log_subscriber.stub(:logger) { logger }
          log_subscriber.render_template(event)
          expect(io.string).to start_with("  Rendered path/to/template.html (2.0ms) @metadata")
        end
      end

      describe "#render_partial" do
        it "should render the collection" do
          log_subscriber = described_class.new
          log_subscriber.stub(:logger) { logger }
          log_subscriber.render_partial(event)
          expect(io.string).to start_with("  Rendered path/to/template.html (2.0ms) @metadata")
        end
      end

      describe "#render_collection" do
        it "should render the collection" do
          log_subscriber = described_class.new
          log_subscriber.stub(:logger) { logger }
          log_subscriber.render_collection(event)

          if log_subscriber.respond_to?(:render_count, true)
            expect(io.string).to start_with("  Rendered collection of path/to/template.html [ times] (2.0ms) @metadata ")
          else
            expect(io.string).to start_with("  Rendered path/to/template.html (2.0ms) @metadata")
          end
        end
      end
    end
  end
end