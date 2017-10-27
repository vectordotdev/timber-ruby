require "spec_helper"

describe Timber::CLI::ConfigFile, :rails_23 => true do
  let(:api) { Timber::CLI::API.new("abcd1234") }
  let(:file_helper) { @file_helper = Timber::CLI::FileHelper.new(api) }
  let(:path) { "config/initializers/timber.rb" }
  let(:config_file) { described_class.new(path, file_helper) }
  let(:initial_contents) { "# Timber.io Ruby Configuration - Simple Structured Logging\n#\n#  ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^\n# /|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# -------------------------------------------------------------------\n# Website:       https://timber.io\n# Documentation: https://timber.io/docs\n# Support:       support@timber.io\n# -------------------------------------------------------------------\n\nconfig = Timber::Config.instance\n\n# Add additional configuration here.\n# For common configuration options see:\n# https://timber.io/docs/languages/ruby/configuration\n#\n# For a full list of configuration options see:\n# http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config\n\n" }
  let(:contents_hook) { "# Add additional configuration here." }

  describe ".create!" do
    it "should create" do
      expect(config_file.file_helper).to receive(:write).with(path, initial_contents).exactly(1).times
      config_file.create!
    end
  end

  describe ".logrageify!" do
    it "should not set the option in the config file" do
      allow(config_file).to receive(:log_rage?).and_return(true)
      config_file.logrageify!
      new_contents = initial_contents.gsub(contents_hook, "config.logrageify!\n\n#{contents_hook}")
      expect(config_file.send(:content)).to eq(new_contents)
    end
  end
end