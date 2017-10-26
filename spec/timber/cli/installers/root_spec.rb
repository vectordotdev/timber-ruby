# encoding: utf-8

require "spec_helper"

describe Timber::CLI::Installers::Root, :rails_23 => true do
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

  describe ".run" do
    it "should run properly" do
      input.string = "y\n"

      expect(installer).to receive(:run_sub_installer).with(app).exactly(1).times
      expect(installer).to receive(:send_test_messages).exactly(1).times
      expect(installer).to receive(:confirm_log_delivery).exactly(1).times
      expect(installer).to receive(:wrap_up).with(app).exactly(1).times
      expect(api).to receive(:event).with(:success).exactly(1).times
      expect(installer).to receive(:collect_feedback).exactly(1).times

      installer.run(app)
    end
  end

  describe ".get_sub_installer" do
    context "with Rails" do
      around(:each) do |example|
        if defined?(Rails)
          example.run
        else
          Rails = true
          example.run
          Object.send(:remove_const, :Rails)
        end
      end

      it "should return Rails" do
        expect(installer.send(:get_sub_installer).class).to eq(Timber::CLI::Installers::Rails)
      end
    end

    context "without Rails" do
      around(:each) do |example|
        if defined?(Rails)
          OldRails = Rails
          Object.send(:remove_const, :Rails)
          example.run
          Rails = OldRails
          Object.send(:remove_const, :OldRails)
        else
          example.run
        end
      end

      it "should return other" do
        expect(installer.send(:get_sub_installer).class).to eq(Timber::CLI::Installers::Other)
      end
    end
  end
end
