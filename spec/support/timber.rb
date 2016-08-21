# Must require last in order to be mocked via webmock
require 'timber'

# Config
Timber::Config.tap do |config|
  config.application_key = "my_key"
  config.logger.level = ::Logger::FATAL
end

RSpec.configure do |config|
  config.after(:each) do
    Timber::CurrentLineIndexes.reset!
    Timber::LogDevices::HTTP::LogPile.each { |log_pile| log_pile.empty }

    # Reset permanent context caches since we mock, etc.
    Timber::CurrentContext.send(:stack).each do |context|
      context.instance_variable_set(:"@as_json", nil)
      context.instance_variable_set(:"@json_payload", nil)
      context.instance_variable_set(:"@to_json", nil)
      context.instance_variable_set(:"@to_logfmt", nil)
    end
  end
end
