require "spec_helper"

describe Timber::Probes::ActionDispatchDebugExceptions do
  describe "#{described_class}::*InstanceMethods" do
    describe "#log_error" do
      let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
      let(:io) { StringIO.new }
      let(:logger) do
        logger = Timber::Logger.new(io)
        logger.level = ::Logger::DEBUG
        logger
      end

      around(:each) do |example|
        class ExceptionController < ActionController::Base
          layout nil

          def index
            raise "boom"
          end

          def method_for_action(action_name)
            action_name
          end
        end

        ::RailsApp.routes.draw do
          get 'exception' => 'exception#index'
        end

        Timecop.freeze(time) { example.run }

        Object.send(:remove_const, :ExceptionController)
      end

      it "should set the context" do
        mock_class
        dispatch_rails_request("/exception")
        message = "RuntimeError (boom):\n\nlib/timber/probes/rack_http_context.rb:18:in `block in call'\nlib/timber/current_context.rb:21:in `with'\nlib/timber/probes/rack_http_context.rb:17:in `call' @timber.io {\"level\":\"datal\",\"dt\":\"2016-09-01T12:00:00.000000Z\",\"event\":{\"exception\":{\"name\":\"RuntimeError\",\"message\":\"boom\",\"backtrace\":[\"lib/timber/probes/rack_http_context.rb:18:in `block in call'\",\"lib/timber/current_context.rb:21:in `with'\",\"lib/timber/probes/rack_http_context.rb:17:in `call'\"]}},\"context\":{\"http\":{\"method\":\"GET\",\"path\":\"/exception\",\"remote_addr\":\"123.456.789.10\",\"request_id\":\"unique-request-id-1234\"}}}\n"
        expect(io.string).to eq(message)
      end

      def mock_class
        klass = defined?(::ActionDispatch::DebugExceptions) ? ::ActionDispatch::DebugExceptions : ::ActionDispatch::ShowExceptions
        allow_any_instance_of(klass).to receive(:logger).and_return(logger)
      end
    end
  end
end