# Must require last in order to be mocked via webmock
require 'timber'

# Config
Timber::Config.tap do |config|
  config.application_key = "my_key"

  # Turn this off for testing, no reason to spin up a thread
  # and send network calls unless the test explicitly calls
  # for it.
  config.log_truck_enabled = false
end