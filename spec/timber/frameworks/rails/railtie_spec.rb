require 'spec_helper'

describe Timber::Frameworks::Rails::Railtie do
  def boot
    RailsApp.initialize!
  end

  before(:each) do
    class RailsApp < Rails::Application
      config.active_support.deprecation = :stderr
      config.logger = Timber::Config.logger
      config.eager_load = false
    end
  end

  after(:each) do
    if Rails.version =~ /^3.0/
      Rails::Application.class_eval do
        @@instance = nil
      end
    end
    Object.send(:remove_const, :RailsApp)
    Rails.application = nil
  end

  describe "initializer" do
    context "with an application_id" do
      before(:each) { Timber::Config.application_id = 123 }

      context "with an application_key" do
        before(:each) { Timber::Config.application_key = "key" }

        it "bootstraps" do
          expect(Timber::Bootstrap).to receive(:bootstrap!).once
          boot
        end

        it "sets the logger" do
          expect(Timber::Config.instance).to receive(:logger=).once
          boot
        end
      end
    end
  end
end
