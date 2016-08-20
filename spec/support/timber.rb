# Must require last in order to be mocked via webmock
require 'timber'

# Config
Timber::Config.tap do |config|
  config.application_key = "my_key"
end

RSpec.configure do |config|
  config.after(:each) do
    Timber::CurrentLineIndexes.reset!
    Timber::LogDevices::HTTP::LogPile.each { |log_pile| log_pile.empty }
  end
end
