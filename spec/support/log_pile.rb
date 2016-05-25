RSpec.configure do |config|
  config.after(:each) do
    Timber::LogPile.empty
  end
end
