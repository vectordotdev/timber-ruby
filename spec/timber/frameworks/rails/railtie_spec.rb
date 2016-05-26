require 'spec_helper'

describe Timber::Frameworks::Rails::Railtie do
  def boot
    RailsApp.initialize!
  end

  before(:each) do
    class RailsApp < Rails::Application
      if Rails.version =~ /^3\./
        config.secret_token = '095f674153982a9ce59914b561f4522a'
      else
        config.secret_key_base = '095f674153982a9ce59914b561f4522a'
      end

      if Rails.version =~ /^3/
        # Workaround for initialization issue with 3.2
        #config.action_view.stylesheet_expansions = {}
        #config.action_view.javascript_expansions = {}
      end

      config.active_support.deprecation = :stderr

      config.logger = Logger.new(STDOUT)
      config.logger.level = Logger::DEBUG

      config.eager_load = false
    end
  end

  after(:each) do
    if Rails.version =~ /^3.0/
      Rails::Application.class_eval do
        @@instance = nil
      end
    end

    # Clean slate
    Object.send(:remove_const, :RailsApp)
    Rails.application = nil
  end

  describe "initializer" do
    it "bootstraps" do
      expect(Timber::Bootstrap).to receive(:bootstrap!).once
      boot
    end
  end
end
