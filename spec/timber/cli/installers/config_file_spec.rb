require "spec_helper"

describe Timber::CLI::Installers::ConfigFile, :rails_23 => true do
  let(:api_key) { "abcd1234" }
  let(:app) do
    attributes = {
      "api_key" => api_key,
      "environment" => "development",
      "framework_type" => "rails",
      "heroku_drain_url" => "http://drain.heroku.com",
      "name" => "My Rails App",
      "platform_type" => "other"
    }
    Timber::CLI::API::Application.new(attributes)
  end
  let(:api) { Timber::CLI::API.new(api_key) }
  let(:input) { StringIO.new }
  let(:output) { StringIO.new }
  let(:io) { Timber::CLI::IO.new(io_out: output, io_in: input) }
  let(:installer) { described_class.new(io, api) }
  let(:initial_config_contents) { "# Timber.io Ruby Configuration - Simple Structured Logging\n#\n#  ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^\n# /|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# -------------------------------------------------------------------\n# Website:       https://timber.io\n# Documentation: https://timber.io/docs\n# Support:       support@timber.io\n# -------------------------------------------------------------------\n\nconfig = Timber::Config.instance\n\n# Add additional configuration here.\n# For a full list of configuration options and their explanations see:\n# http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config\n\n" }

  describe ".run" do
    it "should run properly" do
      path = "/path/to/file"
      config_file = Timber::CLI::ConfigFile.new(path)

      expect(Timber::CLI::ConfigFile).to receive(:new).with(path).and_return(config_file)
      expect(config_file).to receive(:exists?).exactly(1).times.and_return(false)
      expect(installer).to receive(:logrageify?).exactly(1).times.and_return(true)
      expect(config_file).to receive(:logrageify!).exactly(1).times
      expect(config_file).to receive(:create!).exactly(1).times

      installer.run(app, path)
    end
  end

  describe ".logrageify?" do
    it "should do nothing if Lograge is not detected" do
      expect(installer.send(:logrageify?)).to eq(false)
      expect(output.string).to eq("")
    end

    context "with a Lograge constant" do
      around(:each) do |example|
        Lograge = 1
        example.run
        Object.send(:remove_const, :Lograge)
      end

      it "should prompt for Lograge configuration and return true for y" do
        input.string = "y\n"
        expect(installer.send(:logrageify?)).to eq(true)
        expect(output.string).to eq("\n--------------------------------------------------------------------------------\n\nWe noticed you have lograge installed. Would you like to configure \nTimber to function similarly?\n(This silences template renders, sql queries, and controller calls.\nYou can always do this later in config/initialzers/timber.rb)\n\n\e[34my) Yes, configure Timber like lograge\e[0m\n\e[34mn) No, use the Rails logging defaults\e[0m\n\nEnter your choice: (y/n) ")
      end
    end
  end
end