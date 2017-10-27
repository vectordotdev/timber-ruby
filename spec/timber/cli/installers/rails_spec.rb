require "spec_helper"

describe Timber::CLI::Installers::Rails, :rails_23 => true do
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
  let(:logger_code) { defined?(ActiveSupport::TaggedLogging) ? "ActiveSupport::TaggedLogging.new(logger)" : "logger" }

  describe ".run" do
    context "development" do
      it "should execute properly" do
        expect(installer).to receive(:install_initializer).with(app).exactly(1).times
        expect(installer).to receive(:install_development_environment).with(app).exactly(1).times
        expect(installer).to receive(:install_test_environment).with(app).exactly(1).times
        expect(installer).to_not receive(:install_app_environment)

        installer.run(app)
      end
    end

    context "staging" do
      before(:each) do
        app.environment = "staging"
      end

      it "should execute properly" do
        expect(installer).to receive(:install_initializer).with(app).exactly(1).times
        expect(installer).to receive(:install_development_environment).with(app).exactly(1).times
        expect(installer).to receive(:install_test_environment).with(app).exactly(1).times
        expect(installer).to receive(:install_app_environment).with(app).exactly(1).times

        installer.run(app)
      end
    end

    context "production" do
      before(:each) do
        app.environment = "production"
      end

      it "should execute properly" do
        expect(installer).to receive(:install_initializer).with(app).exactly(1).times
        expect(installer).to receive(:install_development_environment).with(app).exactly(1).times
        expect(installer).to receive(:install_test_environment).with(app).exactly(1).times
        expect(installer).to receive(:install_app_environment).with(app).exactly(1).times

        installer.run(app)
      end
    end
  end

  describe ".install_initializer" do
    it "should create a config file" do
      config_file_path = "config/initializers/timber.rb"
      expect_any_instance_of(Timber::CLI::Installers::ConfigFile).to receive(:run).with(app, config_file_path).exactly(1).times

      installer.send(:install_initializer, app)
    end
  end

  describe ".install_development_environment" do
    let(:env_file_path) { "config/environments/development.rb" }

    context "env file exists" do
      context "not installed" do
        context "send logs" do
          it "should setup properly" do
            expect(installer).to receive(:get_environment_file_path).
              with("development").
              exactly(1).times.
              and_return(env_file_path)

            expect(installer).to receive(:already_installed?).
              with(env_file_path).
              exactly(1).times.
              and_return(false)

            expect(installer).to receive(:get_development_preference).
              with(app).
              exactly(1).times.
              and_return(:send)

            expected_code = <<-CODE
  # Install the Timber.io logger
  # ----------------------------
  # Remove the `http_device` to stop sending development logs to Timber.
  # Be sure to keep the `file_device` or replace it with `STDOUT`.
  http_device = Timber::LogDevices::HTTP.new('#{app.api_key}')
  file_device = File.open("\#{Rails.root}/log/development.log", "a")
  file_device.binmode
  log_devices = [http_device, file_device]

  # Do not modify below this line. It's important to keep the `Timber::Logger`
  # because it provides an API for logging structured data and capturing context.
  logger = Timber::Logger.new(*log_devices)
  logger.level = config.log_level
  config.logger = #{logger_code}
CODE

            expect(installer).to receive(:install_logger).
              with(env_file_path, expected_code).
              exactly(1).times

            result = installer.send(:install_development_environment, app)
            expect(result).to eq(:http)
          end
        end

        context "dont send" do
          it "should setup properly" do
            expect(installer).to receive(:get_environment_file_path).
              with("development").
              exactly(1).times.
              and_return(env_file_path)

            expect(installer).to receive(:already_installed?).
              with(env_file_path).
              exactly(1).times.
              and_return(false)

            expect(installer).to receive(:get_development_preference).
              with(app).
              exactly(1).times.
              and_return(:dont_send)

            expect(installer).to receive(:install_stdout).
              with(env_file_path).
              exactly(1).times

            result = installer.send(:install_development_environment, app)
            expect(result).to eq(:stdout)
          end
        end
      end

      context "installed" do
        it "should skip" do
          expect(installer).to receive(:get_environment_file_path).
            with("development").
            exactly(1).times.
            and_return(env_file_path)

          expect(installer).to receive(:already_installed?).
            with(env_file_path).
            exactly(1).times.
            and_return(true)

          result = installer.send(:install_development_environment, app)
          expect(result).to eq(:already_installed)
        end
      end
    end
  end

  describe ".install_test_environment" do
    let(:env_file_path) { "config/environments/test.rb" }

    context "env file exists" do
      context "not installed" do
        it "should setup properly" do
          expect(installer).to receive(:get_environment_file_path).
            with("test").
            exactly(1).times.
            and_return(env_file_path)

          expect(installer).to receive(:already_installed?).
            with(env_file_path).
            exactly(1).times.
            and_return(false)

          expect(installer).to receive(:install_nil).
            with(env_file_path).
            exactly(1).times

          result = installer.send(:install_test_environment, app)
          expect(result).to eq(:nil)
        end
      end

      context "installed" do
        it "should skip" do
          expect(installer).to receive(:get_environment_file_path).
            with("test").
            exactly(1).times.
            and_return(env_file_path)

          expect(installer).to receive(:already_installed?).
            with(env_file_path).
            exactly(1).times.
            and_return(true)

          result = installer.send(:install_test_environment, app)
          expect(result).to eq(:already_installed)
        end
      end
    end
  end

  describe ".install_app_environment" do
    context "production" do
      before(:each) do
        app.environment = "production"
      end

      let(:env_file_path) { "config/environments/production.rb" }

      context "env file exists" do
        context "not installed" do
          context "http" do
            it "should setup properly" do
              expect(installer).to receive(:get_environment_file_path).
                with("production").
                exactly(1).times.
                and_return(env_file_path)

              expect(installer).to receive(:already_installed?).
                with(env_file_path).
                exactly(1).times.
                and_return(false)

              expect(installer).to receive(:get_delivery_strategy).
                with(app).
                exactly(1).times.
                and_return(:http)

              expect(installer).to receive(:get_api_key_storage_preference).
                exactly(1).times.
                and_return(:inline)

              expect(installer).to receive(:install_http).
                with(env_file_path, :inline).
                exactly(1).times

              result = installer.send(:install_app_environment, app)
              expect(result).to eq(:http)
            end
          end

          context "stdout" do
            it "should setup properly" do
              expect(installer).to receive(:get_environment_file_path).
                with("production").
                exactly(1).times.
                and_return(env_file_path)

              expect(installer).to receive(:already_installed?).
                with(env_file_path).
                exactly(1).times.
                and_return(false)

              expect(installer).to receive(:get_delivery_strategy).
                with(app).
                exactly(1).times.
                and_return(:stdout)

              expect(installer).to receive(:install_stdout).
                with(env_file_path).
                exactly(1).times

              result = installer.send(:install_app_environment, app)
              expect(result).to eq(:stdout)
            end
          end
        end

        context "installed" do
          it "should skip" do
            expect(installer).to receive(:get_environment_file_path).
              with("production").
              exactly(1).times.
              and_return(env_file_path)

            expect(installer).to receive(:already_installed?).
              with(env_file_path).
              exactly(1).times.
              and_return(true)

            result = installer.send(:install_app_environment, app)
            expect(result).to eq(:already_installed)
          end
        end
      end
    end
  end

  describe ".get_environment_file_path" do
    it "should return the file if it exists" do
      env_file_path = "config/environments/development.rb"
      expect(installer.file_helper).to receive(:exists?).with(env_file_path).exactly(1).times.and_return(true)

      result = installer.send(:get_environment_file_path, "development")
      expect(result).to eq(env_file_path)
    end

    it "should return nil if it does not exist" do
      env_file_path = "config/environments/production.rb"
      expect(installer.file_helper).to receive(:exists?).with(env_file_path).exactly(1).times.and_return(false)

      result = installer.send(:get_environment_file_path, "production")
      expect(result).to eq(nil)
    end
  end

  describe ".install_nil" do
    it "should pass the proper code" do
      env_file_path = "config/environments/development.rb"

      expected_code = <<-CODE
  # Install the Timber.io logger
  # ----------------------------
  # `nil` is passed to disable logging. It's important to keep the `Timber::Logger`
  # because it provides an API for logging structured data and capturing context.
  logger = Timber::Logger.new(nil)
  logger.level = config.log_level
  config.logger = #{logger_code}
CODE

      expect(installer).to receive(:install_logger).
        with(env_file_path, expected_code).
        exactly(1).times

      installer.send(:install_nil, env_file_path)
    end
  end

  describe ".install_logger" do
    context "not installed" do
      it "should pass the proper code" do
        env_file_path = "config/environments/development.rb"

        logger_code = "my code"

        current_contents = "\nend"

        expect(installer.file_helper).to receive(:read).
          with(env_file_path).
          exactly(1).times.
          and_return(current_contents)

        new_contents = "\n\nmy code\nend"

        expect(installer.file_helper).to receive(:write).
          with(env_file_path, new_contents).
          exactly(1).times.
          and_return("\nend")

        installer.send(:install_logger, env_file_path, logger_code)
      end
    end
  end
end
