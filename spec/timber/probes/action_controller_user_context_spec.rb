require "spec_helper"

describe Timber::Probes::ActionControllerUserContext do
  describe described_class::AroundFilter do
    let(:time) { Time.utc(2016, 9, 1, 12, 0, 0) }
    let(:io) { StringIO.new }
    let(:logger) do
      logger = Timber::Logger.new(io)
      logger.level = ::Logger::WARN
      logger
    end

    around(:each) do |example|
      class UserContextController < ActionController::Base
        layout nil

        def index
          logger.error "test"
          render json: {}
        end

        def method_for_action(action_name)
          action_name
        end

        private
          def current_user
            @current_user ||= begin
              user_struct = Struct.new(:id, :name, :email)
              user_struct.new(1, "Ben Johnson", "hi@timber.io")
            end
          end
      end

      ::RailsApp.routes.draw do
        get 'user_context' => 'user_context#index'
      end

      old_logger = ::ActionController::Base.logger
      ::ActionController::Base.logger = logger

      Timecop.freeze(time) { example.run }

      Object.send(:remove_const, :UserContextController)
      ::ActionController::Base.logger = old_logger
    end

    describe "#index" do
      it "should capture the user context" do
        dispatch_rails_request("/user_context")
        expect(io.string).to include("\"user\":{\"id\":\"1\",\"name\":\"Ben Johnson\",\"email\":\"hi@timber.io\"}")
      end
    end
  end
end