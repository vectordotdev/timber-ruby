require "spec_helper"

describe Timber::Probes::ActiveSupportLogSubscriber::ActiveRecord do
  before(:each) { Timber::Probes::ActiveSupportLogSubscriber.insert! }

  let(:context_class) { Timber::Contexts::ActiveRecordQuery }

  describe "#sql" do
    context "log level debug" do
      before(:each) do
        @old_level = ::ActiveRecord::Base.logger.level
        ::ActiveRecord::Base.logger.level = Logger::DEBUG
      end

      after(:each) { ::ActiveRecord::Base.logger.level = @old_level }

      it "should set the context" do
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(context_class)).and_yield.once
        ActiveRecord::Base.connection.execute("select * from users")
      end
    end
  end
end
