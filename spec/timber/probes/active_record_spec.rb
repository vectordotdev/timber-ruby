require "spec_helper"

describe Timber::Probes::ActiveRecord do
  describe described_class::InstanceMethods do
    before(:each) do
      Timber::Probes::ActiveRecord.insert!

      class User < ::ActiveRecord::Base
      end

      #User.first # get initialization out of the way (has additional queries)
    end

    after(:each) do
      Object.send(:remove_const, :User)
    end

    let(:context_class) { Timber::Contexts::ActiveRecordQuery }

    describe "#sql" do
      xit "should set the context" do
        expect(Timber::CurrentContext).to receive(:add).with(kind_of(context_class)).and_yield.once
        User.first
      end
    end
  end
end
