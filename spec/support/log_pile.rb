RSpec.configure do |config|
  config.after(:each) do
    Timber::LogPile.each { |log_pile| log_pile.empty }
  end
end
