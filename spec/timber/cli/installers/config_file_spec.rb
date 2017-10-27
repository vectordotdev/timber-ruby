require "spec_helper"

describe Timber::CLI::Installers::ConfigFile, :rails_23 => true do
  let(:api_key) { "abcd1234" }
  let(:app) do
    attributes = {
      "api_key" => api_key,
      "environment" => "development",
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
  let(:initial_config_contents) { "# Timber.io Ruby Configuration - Simple Structured Logging\n#\n#  ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^\n# /|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# -------------------------------------------------------------------\n# Website:       https://timber.io\n# Documentation: https://timber.io/docs\n# Support:       support@timber.io\n# -------------------------------------------------------------------\n\nconfig = Timber::Config.instance\n\n# Add additional configuration here.\n# For common configuration options see:\n# https://timber.io/docs/languages/ruby/configuration\n#\n# For a full list of configuration options see:\n# http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config\n\n" }

  describe ".run" do
    it "should run properly" do
      path = "/path/to/file"
      config_file = Timber::CLI::ConfigFile.new(path, installer.file_helper)

      expect(Timber::CLI::ConfigFile).to receive(:new).with(path, installer.file_helper).and_return(config_file)
      expect(config_file).to receive(:exists?).exactly(1).times.and_return(false)
      expect(installer).to receive(:lograge?).exactly(1).times.and_return(true)
      expect(config_file).to receive(:logrageify!).exactly(1).times
      expect(config_file).to receive(:create!).exactly(1).times

      installer.run(app, path)
    end
  end
end
