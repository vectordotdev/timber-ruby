RSpec.configure do |config|
  config.after(:each) do
    Timber::Config.reset!
  end
end
