# encoding: utf-8

require "spec_helper"

describe Timber::CLI::Installers::Other, :rails_23 => true do
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
    context "heroku" do
      before(:each) do
        app.platform_type = "heroku"
      end

      it "should run properly" do
        expect(installer).to receive(:install_stdout).exactly(1).times
        expect(installer).to receive(:ask_to_proceed).exactly(1).times

        installer.run(app)
      end
    end

    context "non-heroku" do
      it "should run properly" do
        api_key_code = "'#{api_key}'"
        expect(installer).to receive(:get_api_key_storage_preference).exactly(1).times.and_return(:inline)
        expect(installer).to receive(:get_api_key_code).with(:inline).exactly(1).times.and_return(api_key_code)
        expect(installer).to receive(:install_http).with(api_key_code).exactly(1).times
        expect(installer).to receive(:ask_to_proceed).exactly(1).times

        installer.run(app)
      end
    end
  end
end
