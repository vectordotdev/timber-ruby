# require "spec_helper"

# describe Timber::CLI::Installers::ConfigFile, :rails_23 => true do
#   let(:api_key) { "abcd1234" }
#   let(:app) do
#     attributes = {
#       "api_key" => api_key,
#       "environment" => "development",
#       "framework_type" => "rails",
#       "heroku_drain_url" => "http://drain.heroku.com",
#       "name" => "My Rails App",
#       "platform_type" => "other"
#     }
#     Timber::CLI::API::Application.new(attributes)
#   end
#   let(:api) { Timber::CLI::API.new(api_key) }
#   let(:input) { StringIO.new }
#   let(:output) { StringIO.new }
#   let(:io) { Timber::CLI::IO.new(io_out: output, io_in: input) }
#   let(:installer) { described_class.new(io, api) }
#   let(:initial_config_contents) { "# Timber.io Ruby Configuration - Simple Structured Logging\n#\n#  ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^\n# /|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# -------------------------------------------------------------------\n# Website:       https://timber.io\n# Documentation: https://timber.io/docs\n# Support:       support@timber.io\n# -------------------------------------------------------------------\n\nconfig = Timber::Config.instance\n\n# Add additional configuration here.\n# For a full list of configuration options and their explanations see:\n# http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config\n\n" }

#   describe ".logrageify?" do
#     it "should do nothing if Lograge is not detected" do
#       expect(installer.send(:logrageify?)).to eq(false)
#       expect(output.string).to eq("")
#     end

#     context "with a Lograge constant" do
#       around(:each) do |example|
#         Lograge = 1
#         example.run
#         Object.send(:remove_const, :Lograge)
#       end

#       it "should prompt for Lograge configuration and return true for y" do
#         input.string = "y\n"
#         expect(installer.send(:logrageify?)).to eq(true)
#         expect(output.string).to eq("\n--------------------------------------------------------------------------------\n\nWe noticed you have lograge installed. Would you like to configure \nTimber to function similarly?\n(This silences template renders, sql queries, and controller calls.\nYou can always do this later in config/initialzers/timber.rb)\n\n\e[34my) Yes, configure Timber like lograge\e[0m\n\e[34mn) No, use the Rails logging defaults\e[0m\n\nEnter your choice: (y/n) ")
#       end
#     end
#   end

#   describe ".logrageify!" do
#     it "should set the option in the config file" do
#       config_file_path = "config/initializers/timber.rb"

#       expect(Timber::CLI::FileHelper).to receive(:read_or_create).
#         with(config_file_path, initial_config_contents).
#         and_return(initial_config_contents)

#       expect(Timber::CLI::FileHelper).to receive(:read).
#         with(config_file_path).
#         and_return(initial_config_contents)

#       new_config_contents = "# Timber.io Ruby Configuration - Simple Structured Logging\n#\n#  ^  ^  ^   ^      ___I_      ^  ^   ^  ^  ^   ^  ^\n# /|\\/|\\/|\\ /|\\    /\\-_--\\    /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   /  \\_-__\\   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# /|\\/|\\/|\\ /|\\   |[]| [] |   /|\\/|\\ /|\\/|\\/|\\ /|\\/|\\\n# -------------------------------------------------------------------\n# Website:       https://timber.io\n# Documentation: https://timber.io/docs\n# Support:       support@timber.io\n# -------------------------------------------------------------------\n\nconfig = Timber::Config.instance\n\nconfig.logrageify!\n\n# Add additional configuration here.\n# For a full list of configuration options and their explanations see:\n# http://www.rubydoc.info/github/timberio/timber-ruby/Timber/Config\n\n"

#       expect(Timber::CLI::FileHelper).to receive(:write).
#         with(config_file_path, new_config_contents).
#         and_return(true)

#       expect(installer.send(:logrageify!)).to eq(true)
#     end
#   end
# end