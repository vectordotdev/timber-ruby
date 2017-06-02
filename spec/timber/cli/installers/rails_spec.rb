require "spec_helper"

describe Timber::CLI::Installers::Rails, :rails_23 => true do
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
    it "should execute properly" do
      expect(installer).to receive(:get_development_preference).exactly(1).times.and_return(:send)
      expect(installer).to receive(:get_api_key_storage_preference).exactly(1).times.and_return(:environment)
      expect(installer).to receive(:logrageify?).exactly(1).times.and_return(true)
      expect(installer).to receive(:initializer).exactly(1).times.and_return(true)
      expect(installer).to receive(:logrageify!).exactly(1).times.and_return(true)
      expect(installer).to receive(:environment_file_paths).exactly(1).times.and_return(["config/environments/development.rb", "config/environments/production.rb", "config/environments/test.rb"])
      expect(installer).to receive(:setup_development_environment).with("config/environments/development.rb", :send).and_return(true)
      expect(installer).to receive(:setup_other_environment).with(app, "config/environments/production.rb", :environment).and_return(true)
      expect(installer).to receive(:setup_test_environment).with("config/environments/test.rb").and_return(true)

      installer.run(app)
    end
  end

  describe ".initializer" do
    it "should create a config file" do
      config_file_path = "config/initializers/timber.rb"

      expect(Timber::CLI::FileHelper).to receive(:read_or_create).
        with(config_file_path, initial_config_contents).
        and_return(initial_config_contents)

      config_file = installer.send(:initializer)
      expect(config_file.path).to eq(config_file_path)
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

  describe ".logrageify!" do
    it "should set the option in the config file" do
      config_file_path = "config/initializers/timber.rb"

      expect(Timber::CLI::FileHelper).to receive(:read_or_create).
        with(config_file_path, initial_config_contents).
        and_return(initial_config_contents)

      expect(Timber::CLI::FileHelper).to receive(:read).
        with(config_file_path).
        and_return(initial_config_contents)

      new_config_contents = "# Timber.io Ruby Configuration - Simple Structured Logging\n#\n#  ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^\n# /|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# -------------------------------------------------------------------\n# Website:       https://timber.io\n# Documentation: https://timber.io/docs\n# Support:       support@timber.io\n# -------------------------------------------------------------------\n\nconfig = Timber::Config.instance\n\nconfig.logrageify!\n\n# Add additional configuration here.\n# For a full list of configuration options and their explanations see:\n# http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config\n\n"

      expect(Timber::CLI::FileHelper).to receive(:write).
        with(config_file_path, new_config_contents).
        and_return(true)

      expect(installer.send(:logrageify!)).to eq(true)
    end
  end

  describe ".setup_development_environment" do
    it "should setup properly" do
      env_file_path = "config/environments/development.rb"

      expect(Timber::CLI::FileHelper).to receive(:read).
        with(env_file_path).
        exactly(2).times.
        and_return("\nend")

      logger_code = defined?(ActiveSupport::TaggedLogging) ? "ActiveSupport::TaggedLogging.new(logger)" : "logger"
      new_contents = "\n\n  # Install the Timber.io logger, send logs over HTTP.\n    # Note: When you are done testing, simply instantiate the logger like this:\n  #\n  #   logger = Timber::Logger.new(STDOUT)\n  #\n  # Be sure to remove the \"log_device =\" and \"logger =\" lines below.\n  log_device = Timber::LogDevices::HTTP.new('abcd1234')\n  logger = Timber::Logger.new(log_device)\n  logger.level = config.log_level\n  config.logger = #{logger_code}\n\nend"

      expect(Timber::CLI::FileHelper).to receive(:write).
        with(env_file_path, new_contents).
        and_return(true)

      expect(api).to receive(:event).with(:file_written, path: env_file_path)

      expect(installer.send(:setup_development_environment, env_file_path, :send)).to eq(true)
    end
  end

  describe ".setup_test_environment" do
    it "should setup properly" do
      env_file_path = "config/environments/test.rb"

      expect(Timber::CLI::FileHelper).to receive(:read).
        with(env_file_path).
        exactly(2).times.
        and_return("\nend")

      logger_code = defined?(ActiveSupport::TaggedLogging) ? "ActiveSupport::TaggedLogging.new(logger)" : "logger"
      new_contents = "\n\n  # Install the Timber.io logger but silence all logs (log to nil). We install the\n  # logger to ensure the Rails.logger object exposes the proper API.\n  logger = Timber::Logger.new(nil)\n  logger.level = config.log_level\n  config.logger = #{logger_code}\n\nend"

      expect(Timber::CLI::FileHelper).to receive(:write).
        with(env_file_path, new_contents).
        and_return(true)

      expect(api).to receive(:event).with(:file_written, path: env_file_path)

      expect(installer.send(:setup_test_environment, env_file_path)).to eq(true)
    end
  end

  describe ".setup_other_environment" do
    it "should setup properly" do
      env_file_path = "config/environments/production.rb"

      expect(Timber::CLI::FileHelper).to receive(:read).
        with(env_file_path).
        exactly(2).times.
        and_return("\nend")

      logger_code = defined?(ActiveSupport::TaggedLogging) ? "ActiveSupport::TaggedLogging.new(logger)" : "logger"
      new_contents = "\n\n  # Install the Timber.io logger, send logs over HTTP.\n  log_device = Timber::LogDevices::HTTP.new(ENV['TIMBER_API_KEY'])\n  logger = Timber::Logger.new(log_device)\n  logger.level = config.log_level\n  config.logger = #{logger_code}\n\nend"

      expect(Timber::CLI::FileHelper).to receive(:write).
        with(env_file_path, new_contents).
        and_return(true)

      expect(api).to receive(:event).with(:file_written, path: env_file_path).exactly(1).times

      expect(installer.send(:setup_other_environment, app, env_file_path, :environment)).to eq(true)
    end
  end
end