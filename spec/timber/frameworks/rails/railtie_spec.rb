require 'spec_helper'

describe Timber::Frameworks::Rails::Railtie do
  def boot
    RailsApp.initialize!
  end

  before(:each) do
    class RailsApp < Rails::Application
      if Rails.version =~ /^3\./
        config.secret_token = '1e05af2b349457936a41427e63450937'
      else
        config.secret_key_base = '1e05af2b349457936a41427e63450937'
      end
      config.active_support.deprecation = :stderr
      config.logger = Logger.new(STDOUT)
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
    context "with an application_key" do
      before(:each) { Timber::Config.application_key = "key" }
      after(:each) { Timber::Config.application_key = nil }

      it "bootstraps" do
        expect(Timber::Bootstrap).to receive(:bootstrap!).once
        expect(Timber::Config.instance).to receive(:logger=).once
        boot
      end
    end
  end
end
